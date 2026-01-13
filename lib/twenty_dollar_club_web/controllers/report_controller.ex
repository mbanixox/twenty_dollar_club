defmodule TwentyDollarClubWeb.ReportController do
  @moduledoc """
  Handles Excel report generation requests.
  """

  use TwentyDollarClubWeb, :controller

  require Logger

  @doc """
  Generates an Excel report for the specified type.

  Supported report types: memberships, projects, contributions
  """
  def generate(conn, %{"report_type" => report_type}) do
    user = conn.assigns.user

    # Validate report type
    if report_type in ["memberships", "projects", "contributions"] do
      # Enqueue the report generation job
      %{
        report_type: report_type,
        user_id: user.id
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
            message: "A similar report is already being generated. Please wait a few minutes and try again."
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
      reports_dir = Path.join([Application.app_dir(:twenty_dollar_club, "priv"), "static", "reports"])
      file_path = Path.join(reports_dir, filename)

      # Security: Ensure file is in reports directory and exists
      if String.starts_with?(file_path, reports_dir) and File.exists?(file_path) do
        conn
        |> put_resp_content_type("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
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
end
