defmodule TwentyDollarClub.ProjectContributions do
  @moduledoc """
  The ProjectContributions context.
  """

  import Ecto.Query, warn: false
  alias TwentyDollarClub.Repo

  alias TwentyDollarClub.ProjectContributions.ProjectContribution

  @doc """
  Returns the list of project_contributions.

  ## Examples

      iex> list_project_contributions()
      [%ProjectContribution{}, ...]

  """
  def list_project_contributions do
    Repo.all(ProjectContribution)
  end

  @doc """
  Gets a single project_contribution.

  Raises `Ecto.NoResultsError` if the Project contribution does not exist.

  ## Examples

      iex> get_project_contribution!(123)
      %ProjectContribution{}

      iex> get_project_contribution!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_contribution!(id), do: Repo.get!(ProjectContribution, id)

  @doc """
  Creates a project_contribution.

  ## Examples

      iex> create_project_contribution(%{field: value})
      {:ok, %ProjectContribution{}}

      iex> create_project_contribution(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_contribution(attrs) do
    %ProjectContribution{}
    |> ProjectContribution.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project_contribution.

  ## Examples

      iex> update_project_contribution(project_contribution, %{field: new_value})
      {:ok, %ProjectContribution{}}

      iex> update_project_contribution(project_contribution, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_contribution(%ProjectContribution{} = project_contribution, attrs) do
    project_contribution
    |> ProjectContribution.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project_contribution.

  ## Examples

      iex> delete_project_contribution(project_contribution)
      {:ok, %ProjectContribution{}}

      iex> delete_project_contribution(project_contribution)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_contribution(%ProjectContribution{} = project_contribution) do
    Repo.delete(project_contribution)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project_contribution changes.

  ## Examples

      iex> change_project_contribution(project_contribution)
      %Ecto.Changeset{data: %ProjectContribution{}}

  """
  def change_project_contribution(%ProjectContribution{} = project_contribution, attrs \\ %{}) do
    ProjectContribution.changeset(project_contribution, attrs)
  end
end
