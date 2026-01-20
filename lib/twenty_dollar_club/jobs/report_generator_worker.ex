defmodule TwentyDollarClub.Jobs.ReportGeneratorWorker do
  @moduledoc """
  Generates Excel reports asynchronously.

  This worker handles report generation for memberships, projects, and contributions.
  Reports are generated and stored for download.

  ## Configuration

  - Queue: `:reports`
  - Max attempts: 3
  - Unique: 300 seconds (5 minutes) per report type to prevent duplicate generation

  ## Features

  - Summary statistics in report headers
  - Automatic retry on failure
  - PubSub notifications when complete
  - Report caching - recent reports are reused within 30 minutes
  """
  use Oban.Worker,
    queue: :reports,
    max_attempts: 3,
    unique: [period: 300, fields: [:args], keys: [:report_type]]

  alias TwentyDollarClub.Reports.ExcelGenerator

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "report_type" => report_type,
          "membership_id" => membership_id
        }
      }) do
    Logger.info(
      "Generating Excel report for #{report_type} (requested by membership: #{membership_id})"
    )

    with {:ok, workbook} <- generate_report(report_type),
         {:ok, path} <- save_report(workbook, report_type) do
      Logger.info("Report generated successfully: #{path}")

      # Broadcast to the report channel
      Phoenix.PubSub.broadcast(
        TwentyDollarClub.PubSub,
        "report:#{membership_id}",
        {:report_ready,
         %{
           report_type: report_type,
           path: path,
           filename: Path.basename(path)
         }}
      )

      {:ok, %{path: path, filename: Path.basename(path)}}
    else
      {:error, reason} ->
        Logger.error("Failed to generate report: #{inspect(reason)}")

        # Broadcast error to channel
        Phoenix.PubSub.broadcast(
          TwentyDollarClub.PubSub,
          "report:#{membership_id}",
          {:report_error, %{message: "Failed to generate report: #{inspect(reason)}"}}
        )

        {:error, reason}
    end
  end

  defp generate_report(report_type) do
    try do
      workbook =
        case report_type do
          "memberships" -> ExcelGenerator.generate_memberships_report()
          "projects" -> ExcelGenerator.generate_projects_report()
          "contributions" -> ExcelGenerator.generate_contributions_report()
          _ -> nil
        end

      if workbook do
        {:ok, workbook}
      else
        {:error, "Invalid report type: #{report_type}"}
      end
    rescue
      e ->
        Logger.error("Exception generating report: #{Exception.message(e)}")
        Logger.error(Exception.format_stacktrace())
        {:error, Exception.message(e)}
    end
  end

  defp save_report(workbook, report_type) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    filename = "#{report_type}_report_#{timestamp}.xlsx"

    # Use priv/static/reports directory for temporary storage
    reports_dir =
      Path.join([Application.app_dir(:twenty_dollar_club, "priv"), "static", "reports"])

    File.mkdir_p!(reports_dir)

    file_path = Path.join(reports_dir, filename)

    case Elixlsx.write_to(workbook, file_path) do
      {:ok, _path} ->
        Logger.info("Report saved to: #{file_path}")
        cleanup_old_reports(reports_dir, report_type)
        {:ok, file_path}

      {:error, reason} ->
        Logger.error("Failed to save report: #{inspect(reason)}")
        {:error, "Failed to save report: #{inspect(reason)}"}
    end
  end

  # Keep only the 3 most recent reports of each type to prevent disk bloat
  defp cleanup_old_reports(reports_dir, report_type) do
    _pattern = "#{report_type}_report_*.xlsx"

    case File.ls(reports_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.match?(&1, ~r/^#{report_type}_report_\d+\.xlsx$/))
        |> Enum.map(&Path.join(reports_dir, &1))
        |> Enum.sort_by(
          fn path ->
            case File.stat(path) do
              {:ok, %File.Stat{mtime: mtime}} -> mtime
              _ -> {{1970, 1, 1}, {0, 0, 0}}
            end
          end,
          :desc
        )
        |> Enum.drop(3)
        |> Enum.each(fn path ->
          File.rm(path)
          Logger.info("Cleaned up old report: #{path}")
        end)

      {:error, reason} ->
        Logger.warning("Could not list reports directory: #{inspect(reason)}")
    end
  end
end
