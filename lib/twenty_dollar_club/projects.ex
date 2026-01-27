defmodule TwentyDollarClub.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias TwentyDollarClub.Repo

  alias TwentyDollarClub.Projects.Project
  alias TwentyDollarClub.Memberships.Membership
  alias TwentyDollarClub.Notifications

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs) do
    %Project{}
    |> Project.create_changeset(attrs)
    |> Repo.insert()
    |> notify_new_project()
  end

  defp notify_new_project({:ok, project}) do
    member_ids =
      Membership
      |> Repo.all()
      |> Enum.map(& &1.id)

    Enum.each(member_ids, fn membership_id ->
      Notifications.create_notification(
        %{
          event: :new_project_created,
          message: "A new project '#{project.title}' has been created.",
          severity: :medium,
          recipient_type: :member,
          resource_type: :project
        },
        membership_id
      )
    end)

    {:ok, project}
  end

  defp notify_new_project(error), do: error

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
    |> notify_project_update()
  end

  defp notify_project_update({:ok, project}) do
    member_ids =
      Membership
      |> Repo.all()
      |> Enum.map(& &1.id)

    Enum.each(member_ids, fn membership_id ->
      Notifications.create_notification(
        %{
          event: :project_updated,
          message: "Project '#{project.title}' has been updated.",
          severity: :medium,
          recipient_type: :member,
          resource_type: :project
        },
        membership_id
      )
    end)

    {:ok, project}
  end

  defp notify_project_update(error), do: error

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    project
    |>Repo.delete()
    |> notify_project_deletion()
  end

  defp notify_project_deletion({:ok, project}) do
    member_ids =
      Membership
      |> Repo.all()
      |> Enum.map(& &1.id)

    Enum.each(member_ids, fn membership_id ->
      Notifications.create_notification(
        %{
          event: :project_deleted,
          message: "Project '#{project.title}' has been deleted.",
          severity: :medium,
          recipient_type: :member,
          resource_type: :project
        },
        membership_id
      )
    end)

    {:ok, project}
  end

  defp notify_project_deletion(error), do: error

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Recalculates and updates the funded amount for a project based on its completed contributions.

  ## Examples

      iex> update_funded_amount_from_contributions(project_id)
      {:ok, %Project{}}
  """
  def update_funded_amount_from_contributions(project_id) do
    funded_amount =
      TwentyDollarClub.Contributions.sum_completed_contributions_for_project(project_id)

    project = get_project!(project_id)
    update_project(project, %{funded_amount: funded_amount})
  end
end
