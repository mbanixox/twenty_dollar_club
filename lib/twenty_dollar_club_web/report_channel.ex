defmodule TwentyDollarClubWeb.ReportChannel do
  use TwentyDollarClubWeb, :channel

  require Logger

  @impl true
  def join("report:" <> membership_id, _params, socket) do
    Logger.info("Member #{membership_id} joined report channel")

    # Subscribe to PubSub for this member's reports
    Phoenix.PubSub.subscribe(TwentyDollarClub.PubSub, "report:#{membership_id}")
    {:ok, assign(socket, :membership_id, membership_id)}
  end

  @impl true
  def handle_in("generate_report", %{"report_type" => report_type}, socket) do
    membership_id = socket.assigns.membership_id

    # Enqueue the report generation job
    case TwentyDollarClub.Jobs.ReportGeneratorWorker.new(%{
           report_type: report_type,
           membership_id: membership_id
         })
         |> Oban.insert() do
      {:ok, _job} ->
        Logger.info("Report generation job enqueued for #{report_type} (membership: #{membership_id})")
        {:reply, {:ok, %{status: "processing"}}, socket}

      {:error, reason} ->
        Logger.error("Failed to enqueue report job: #{inspect(reason)}")
        {:reply, {:error, %{reason: "Failed to start report generation"}}, socket}
    end
  end

  @impl true
  def handle_info({:report_ready, report_data}, socket) do
    # Push notification to client when report is ready
    push(socket, "report_ready", %{
      report_type: report_data.report_type,
      filename: report_data.filename,
      download_url: "/reports/download/#{report_data.filename}"
    })

    {:noreply, socket}
  end
end
