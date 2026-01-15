defmodule TwentyDollarClubWeb.ReportController do
  @moduledoc """
  Handles Excel report generation requests.
  """

  use TwentyDollarClubWeb, :controller

  require Logger

  # Reports are considered fresh for 30 minutes
  @report_freshness_minutes 30

  @doc """
  Generates an Excel report for the specified type.

  Supported report types: memberships, projects, contributions

  If a recent report exists (within 30 minutes), it will be returned immediately.
  Otherwise, a new report generation job will be enqueued.
  """
  def generate(conn, %{"report_type" => report_type}) do
    membership = conn.assigns.user.membership

    # Validate report type
    if report_type in ["memberships", "projects", "contributions"] do
      case check_existing_report(report_type) do
        {:ok, existing_file} ->
          Logger.info("Returning existing report: #{existing_file}")

          conn
          |> put_status(:ok)
          |> json(%{
            status: "success",
            message: "Report already available",
            report_type: report_type,
            filename: Path.basename(existing_file),
            download_url: "/api/reports/download/#{Path.basename(existing_file)}",
            cached: true
          })

        {:error, :not_found} ->
          enqueue_report_job(conn, report_type, membership.id)
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{
        status: "error",
        message: "Invalid report type. Must be: memberships, projects, or contributions"
      })
    end
  end

  @doc """
  Downloads a generated report file.
  """
  def download(conn, %{"filename" => filename}) do
    # Security: Only allow .xlsx files
    if String.ends_with?(filename, ".xlsx") do
      reports_dir = get_reports_dir()
      file_path = Path.join(reports_dir, filename)

      # Security: Ensure file is in reports directory and exists
      if String.starts_with?(file_path, reports_dir) and File.exists?(file_path) do
        conn
        |> put_resp_content_type(
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        )
        |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
        |> send_file(200, file_path)
      else
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Report not found"})
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{status: "error", message: "Invalid file type"})
    end
  end

  # Private functions

  defp enqueue_report_job(conn, report_type, membership_id) do
    %{
      report_type: report_type,
      membership_id: membership_id
    }
    |> TwentyDollarClub.Jobs.ReportGeneratorWorker.new()
    |> Oban.insert()
    |> case do
      {:ok, job} ->
        Logger.info("Report generation job enqueued: #{job.id}")

        conn
        |> put_status(:accepted)
        |> json(%{
          status: "success",
          message: "Excel report generation started. You will be notified when it's ready.",
          job_id: job.id,
          report_type: report_type
        })

      {:error, %Ecto.Changeset{}} ->
        # Job already exists (uniqueness constraint)
        Logger.warning("Duplicate report request detected")

        conn
        |> put_status(:conflict)
        |> json(%{
          status: "error",
          message:
            "A similar report is already being generated. Please wait a few minutes and try again."
        })

      {:error, reason} ->
        Logger.error("Failed to enqueue report job: #{inspect(reason)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: "Failed to start report generation"
        })
    end
  end

  defp check_existing_report(report_type) do
    reports_dir = get_reports_dir()
    _pattern = "#{report_type}_report_*.xlsx"

    case File.ls(reports_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.match?(&1, ~r/^#{report_type}_report_\d+\.xlsx$/))
        |> Enum.map(&{&1, Path.join(reports_dir, &1)})
        |> Enum.filter(fn {_name, path} -> File.exists?(path) end)
        |> Enum.sort_by(
          fn {_name, path} ->
            case File.stat(path) do
              {:ok, %File.Stat{mtime: mtime}} -> mtime
              _ -> {{1970, 1, 1}, {0, 0, 0}}
            end
          end,
          :desc
        )
        |> case do
          [] ->
            {:error, :not_found}

          [{filename, path} | _rest] ->
            if report_is_fresh?(path) do
              {:ok, path}
            else
              Logger.info("Report #{filename} is stale, will generate new one")
              {:error, :not_found}
            end
        end

      {:error, _reason} ->
        {:error, :not_found}
    end
  end

  defp report_is_fresh?(file_path) do
    case File.stat(file_path) do
      {:ok, %File.Stat{mtime: mtime}} ->
        # Convert Erlang datetime tuple to DateTime
        mtime_datetime = mtime |> NaiveDateTime.from_erl!() |> DateTime.from_naive!("Etc/UTC")
        now = DateTime.utc_now()

        diff_minutes = DateTime.diff(now, mtime_datetime, :minute)
        diff_minutes < @report_freshness_minutes

      {:error, _reason} ->
        false
    end
  end

  defp get_reports_dir do
    Path.join([Application.app_dir(:twenty_dollar_club, "priv"), "static", "reports"])
  end
end
