defmodule TwentyDollarClub.Reports.ExcelGenerator do
  @moduledoc """
  Excel report generator using Elixlsx.

  Generates formatted Excel spreadsheets with:
  - Data validation and formatting
  - Multiple sheets when needed
  - Summary statistics
  - Styling with colors
  """

  alias Elixlsx.{Workbook, Sheet}
  alias TwentyDollarClub.{Memberships, Projects, Contributions, Repo}
  import Ecto.Query

  require Logger

  @title_style [bold: true, size: 14, color: "#FFFFFF", bg_color: "#4472C4"]

  @header_style [bold: true, size: 11, color: "#FFFFFF", bg_color: "#5B9BD5"]

  @summary_label_style [bold: true, size: 11, bg_color: "#D9E1F2"]

  @summary_value_style [size: 11, bg_color: "#D9E1F2"]

  @data_style [size: 10]

  @alternating_row_style [size: 10, bg_color: "#F2F2F2"]

  @doc """
  Generates a memberships report.
  """
  def generate_memberships_report do
    memberships =
      from(m in Memberships.Membership,
        preload: [:user],
        order_by: [desc: m.inserted_at]
      )
      |> Repo.all()

    total_count = length(memberships)
    role_counts = Enum.frequencies_by(memberships, & &1.role)

    title_row = [
      [["Membership Report - Generated: #{format_datetime(DateTime.utc_now())}" | @title_style]]
    ]

    summary_rows = [
      [],
      [["Total Memberships:" | @summary_label_style], [total_count | @summary_value_style]],
      [["Members:" | @summary_label_style], [Map.get(role_counts, :member, 0) | @summary_value_style]],
      [["Admins:" | @summary_label_style], [Map.get(role_counts, :admin, 0) | @summary_value_style]],
      [["Super Admins (Developers):" | @summary_label_style], [Map.get(role_counts, :super_admin, 0) | @summary_value_style]],
      []
    ]

    header_row = [
      Enum.map(
        ["ID", "Member ID", "User Email", "Name", "Role", "Created At", "Updated At"],
        &[&1 | @header_style]
      )
    ]

    data_rows =
      memberships
      |> Enum.with_index()
      |> Enum.map(fn {m, index} ->
        style = if rem(index, 2) == 0, do: @data_style, else: @alternating_row_style

        [
          [safe_string(m.id) | style],
          [safe_string(m.generated_id) | style],
          [safe_string(m.user.email) | style],
          [format_name(Map.get(m.user, :first_name), Map.get(m.user, :last_name)) | style],
          [format_role(m.role) | style],
          [format_datetime(m.inserted_at) | style],
          [format_datetime(m.updated_at) | style]
        ]
      end)

    rows = title_row ++ summary_rows ++ header_row ++ data_rows

    sheet = %Sheet{name: "Memberships", rows: rows, merge_cells: [{"A1", "C1"}]}

    sheet
    |> Sheet.set_col_width("A", 40.0)
    |> Sheet.set_col_width("B", 15.0)
    |> Sheet.set_col_width("C", 30.0)
    |> Sheet.set_col_width("D", 25.0)
    |> Sheet.set_col_width("E", 20.0)
    |> Sheet.set_col_width("F", 22.0)
    |> Sheet.set_col_width("G", 22.0)
    |> then(&%Workbook{sheets: [&1]})
  end

  @doc """
  Generates a projects report with funding analysis.
  """
  def generate_projects_report do
    projects =
      from(p in Projects.Project,
        order_by: [desc: p.inserted_at]
      )
      |> Repo.all()

    Logger.info("Generating report for #{length(projects)} projects")

    total_projects = length(projects)

    total_goal =
      Enum.reduce(projects, Decimal.new(0), fn p, acc ->
        Decimal.add(acc, p.goal_amount || Decimal.new(0))
      end)

    total_funded =
      Enum.reduce(projects, Decimal.new(0), fn p, acc ->
        Decimal.add(acc, p.funded_amount || Decimal.new(0))
      end)

    overall_progress = calculate_percentage(total_funded, total_goal)
    status_counts = Enum.frequencies_by(projects, & &1.status)

    title_row = [
      [["Projects Report - Generated: #{format_datetime(DateTime.utc_now())}" | @title_style]]
    ]

    summary_rows = [
      [],
      [["Total Projects:" | @summary_label_style], [safe_number(total_projects) | @summary_value_style]],
      [["Total Goal Amount:" | @summary_label_style], [safe_currency(total_goal) | @summary_value_style]],
      [["Total Funded:" | @summary_label_style], [safe_currency(total_funded) | @summary_value_style]],
      [["Overall Progress:" | @summary_label_style], ["#{overall_progress}%" | @summary_value_style]],
      [],
      [["Status Breakdown:" | @summary_label_style]],
      [["Active:" | @summary_label_style], [safe_number(Map.get(status_counts, :active, 0)) | @summary_value_style]],
      [["Completed:" | @summary_label_style], [safe_number(Map.get(status_counts, :completed, 0)) | @summary_value_style]],
      [["Paused:" | @summary_label_style], [safe_number(Map.get(status_counts, :paused, 0)) | @summary_value_style]],
      []
    ]

    header_row = [
      Enum.map(
        ["ID", "Title", "Description", "Status", "Goal Amount (KSh)", "Funded Amount (KSh)", "Progress %", "Created At"],
        &[&1 | @header_style]
      )
    ]

    data_rows =
      projects
      |> Enum.with_index()
      |> Enum.map(fn {p, index} ->
        style = if rem(index, 2) == 0, do: @data_style, else: @alternating_row_style
        progress = calculate_percentage(p.funded_amount, p.goal_amount)

        [
          [safe_string(p.id) | style],
          [safe_string(p.title) | style],
          [safe_string(Map.get(p, :description)) | style],
          [format_status(p.status) | style],
          [safe_decimal(p.goal_amount) | style],
          [safe_decimal(p.funded_amount) | style],
          ["#{progress}%" | style],
          [format_datetime(p.inserted_at) | style]
        ]
      end)

    rows = title_row ++ summary_rows ++ header_row ++ data_rows

    Logger.info("Total rows in sheet: #{length(rows)}")

    sheet = %Sheet{name: "Projects", rows: rows, merge_cells: [{"A1", "C1"}]}

    sheet
    |> Sheet.set_col_width("A", 40.0)
    |> Sheet.set_col_width("B", 30.0)
    |> Sheet.set_col_width("C", 45.0)
    |> Sheet.set_col_width("D", 15.0)
    |> Sheet.set_col_width("E", 20.0)
    |> Sheet.set_col_width("F", 22.0)
    |> Sheet.set_col_width("G", 15.0)
    |> Sheet.set_col_width("H", 22.0)
    |> then(&%Workbook{sheets: [&1]})
  end

  @doc """
  Generates a contributions report with payment analysis.
  """
  def generate_contributions_report do
    contributions =
      from(c in Contributions.Contribution,
        preload: [:membership, :project],
        order_by: [desc: c.inserted_at]
      )
      |> Repo.all()

    Logger.info("Generating report for #{length(contributions)} contributions")

    total_contributions = length(contributions)

    completed_amount =
      contributions
      |> Enum.filter(&(&1.status == :completed))
      |> Enum.reduce(Decimal.new(0), fn c, acc ->
        Decimal.add(acc, c.amount || Decimal.new(0))
      end)

    pending_amount =
      contributions
      |> Enum.filter(&(&1.status == :pending))
      |> Enum.reduce(Decimal.new(0), fn c, acc ->
        Decimal.add(acc, c.amount || Decimal.new(0))
      end)

    status_counts = Enum.frequencies_by(contributions, & &1.status)
    type_counts = Enum.frequencies_by(contributions, & &1.contribution_type)
    method_counts = Enum.frequencies_by(contributions, &(Map.get(&1, :payment_method) || :unknown))

    title_row = [
      [["Contributions Report - Generated: #{format_datetime(DateTime.utc_now())}" | @title_style]]
    ]

    summary_rows = [
      [],
      [["Total Contributions:" | @summary_label_style], [safe_number(total_contributions) | @summary_value_style]],
      [["Completed Amount:" | @summary_label_style], [safe_currency(completed_amount) | @summary_value_style]],
      [["Pending Amount:" | @summary_label_style], [safe_currency(pending_amount) | @summary_value_style]],
      [],
      [["By Status:" | @summary_label_style]],
      [["Completed:" | @summary_label_style], [safe_number(Map.get(status_counts, :completed, 0)) | @summary_value_style]],
      [["Pending:" | @summary_label_style], [safe_number(Map.get(status_counts, :pending, 0)) | @summary_value_style]],
      [["Failed:" | @summary_label_style], [safe_number(Map.get(status_counts, :failed, 0)) | @summary_value_style]],
      [["Cancelled:" | @summary_label_style], [safe_number(Map.get(status_counts, :cancelled, 0)) | @summary_value_style]],
      [],
      [["By Type:" | @summary_label_style]],
      [["Membership:" | @summary_label_style], [safe_number(Map.get(type_counts, :membership, 0)) | @summary_value_style]],
      [["Project:" | @summary_label_style], [safe_number(Map.get(type_counts, :project, 0)) | @summary_value_style]],
      [],
      [["By Payment Method:" | @summary_label_style]],
      [["M-Pesa:" | @summary_label_style], [safe_number(Map.get(method_counts, :mpesa, 0)) | @summary_value_style]],
      [["Card:" | @summary_label_style], [safe_number(Map.get(method_counts, :card, 0)) | @summary_value_style]],
      [["Cash:" | @summary_label_style], [safe_number(Map.get(method_counts, :cash, 0)) | @summary_value_style]],
      [["Unknown:" | @summary_label_style], [safe_number(Map.get(method_counts, :unknown, 0)) | @summary_value_style]],
      []
    ]

    header_row = [
      Enum.map(
        ["ID", "Type", "Amount (KSh)", "Status", "Method", "Transaction Ref", "Email", "Phone", "Description", "Related To", "Membership ID", "Created At"],
        &[&1 | @header_style]
      )
    ]

    data_rows =
      contributions
      |> Enum.with_index()
      |> Enum.map(fn {c, index} ->
        style = if rem(index, 2) == 0, do: @data_style, else: @alternating_row_style
        related_to = get_related_entity(c)

        membership_id =
          if c.membership do
            safe_string(c.membership.generated_id)
          else
            "N/A"
          end

        [
          [safe_string(c.id) | style],
          [format_contribution_type(c.contribution_type) | style],
          [safe_decimal(c.amount) | style],
          [format_status(c.status) | style],
          [format_payment_method(Map.get(c, :payment_method)) | style],
          [safe_string(Map.get(c, :transaction_reference)) | style],
          [safe_string(c.email) | style],
          [safe_string(Map.get(c, :phone_number)) | style],
          [safe_string(Map.get(c, :description)) | style],
          [related_to | style],
          [membership_id | style],
          [format_datetime(c.inserted_at) | style]
        ]
      end)

    rows = title_row ++ summary_rows ++ header_row ++ data_rows

    sheet = %Sheet{name: "Contributions", rows: rows, merge_cells: [{"A1", "C1"}]}

    sheet
    |> Sheet.set_col_width("A", 40.0)
    |> Sheet.set_col_width("B", 14.0)
    |> Sheet.set_col_width("C", 15.0)
    |> Sheet.set_col_width("D", 12.0)
    |> Sheet.set_col_width("E", 12.0)
    |> Sheet.set_col_width("F", 25.0)
    |> Sheet.set_col_width("G", 30.0)
    |> Sheet.set_col_width("H", 15.0)
    |> Sheet.set_col_width("I", 35.0)
    |> Sheet.set_col_width("J", 35.0)
    |> Sheet.set_col_width("K", 15.0)
    |> Sheet.set_col_width("L", 22.0)
    |> then(&%Workbook{sheets: [&1]})
  end

  defp format_name(first_name, last_name) do
    fs_name = first_name |> safe_string() |> String.capitalize()
    ls_name = last_name |> safe_string() |> String.capitalize()

    "#{fs_name} #{ls_name}"
  end

  defp safe_string(nil), do: "N/A"
  defp safe_string(value) when is_binary(value), do: value
  defp safe_string(value) when is_atom(value), do: Atom.to_string(value)
  defp safe_string(value), do: to_string(value)

  defp safe_number(nil), do: 0
  defp safe_number(value) when is_integer(value), do: value
  defp safe_number(value) when is_float(value), do: value
  defp safe_number(_value), do: 0

  defp safe_decimal(nil), do: "0.00"
  defp safe_decimal(%Decimal{} = value), do: Decimal.to_string(value)
  defp safe_decimal(value) when is_number(value), do: to_string(value)
  defp safe_decimal(_), do: "0.00"

  defp safe_currency(nil), do: "KSh 0.00"
  defp safe_currency(%Decimal{} = value), do: "KSh #{Decimal.to_string(value)}"
  defp safe_currency(value) when is_number(value), do: "KSh #{value}"
  defp safe_currency(_), do: "KSh 0.00"

  defp format_datetime(nil), do: "N/A"

  defp format_datetime(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S UTC")
  end

  defp format_datetime(%NaiveDateTime{} = datetime) do
    Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")
  end

  defp format_datetime(_), do: "N/A"

  defp format_role(role) when is_atom(role) do
    role |> Atom.to_string() |> String.upcase() |> String.replace("_", " ")
  end

  defp format_role(_), do: "UNKNOWN"

  defp format_status(status) when is_atom(status),
    do: status |> Atom.to_string() |> String.upcase()

  defp format_status(_), do: "UNKNOWN"

  defp format_contribution_type(type) when is_atom(type) do
    type |> Atom.to_string() |> String.upcase()
  end

  defp format_contribution_type(_), do: "UNKNOWN"

  defp format_payment_method(nil), do: "N/A"

  defp format_payment_method(method) when is_atom(method) do
    method |> Atom.to_string() |> String.upcase()
  end

  defp format_payment_method(_), do: "N/A"

  defp calculate_percentage(funded, goal) do
    funded = funded || Decimal.new(0)
    goal = goal || Decimal.new(0)

    if Decimal.compare(goal, 0) == :gt do
      funded
      |> Decimal.div(goal)
      |> Decimal.mult(100)
      |> Decimal.round(2)
      |> Decimal.to_string()
    else
      "0.00"
    end
  end

  defp get_related_entity(contribution) do
    cond do
      contribution.project && Map.get(contribution.project, :title) ->
        "Project: #{contribution.project.title}"

      contribution.membership_id ->
        "Membership Payment"

      true ->
        "N/A"
    end
  end
end
