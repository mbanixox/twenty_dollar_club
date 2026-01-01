defmodule TwentyDollarClub.Contributions do
  @moduledoc """
  The Contributions context.
  """

  import Ecto.Query, warn: false
  alias TwentyDollarClub.Repo
  alias TwentyDollarClub.Contributions.{Contribution, MpesaTransaction}

  @doc """
  Returns the list of contributions.
  """
  def list_contributions do
    Repo.all(Contribution)
  end

  @doc """
  Gets a single contribution.

  Raises `Ecto.NoResultsError` if the Contribution does not exist.

  ## Examples

      iex> get_contribution!(123)
      %Contribution{}

      iex> get_contribution!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contribution!(id), do: Repo.get!(Contribution, id)

  @doc """
  Creates a pending contribution without membership (for initial payment).

  ## Examples

      iex> create_pending_contribution(%{field: value})
      {:ok, %Contribution{}}

      iex> create_pending_contribution(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pending_contribution(attrs) do
    attrs
    |> Contribution.create_changeset()
    |> Repo.insert()
  end

  @doc """
  Creates a contribution for an existing membership.

  ## Examples

      iex> create_contribution(membership_id, %{field: value})
      {:ok, %Contribution{}}

      iex> create_contribution(membership_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contribution(membership_id, attrs) do
    attrs
    |> Map.put(:membership_id, membership_id)
    |> Contribution.create_changeset()
    |> Repo.insert()
  end

  @doc """
  Updates contribution to link it to a membership after payment.

  ## Examples

      iex> update_contribution_membership(contribution, membership_id)
      {:ok, %Contribution{}}

      iex> update_contribution_membership(contribution, bad_membership_id)
      {:error, %Ecto.Changeset{}}

  """
  def update_contribution_membership(contribution, membership_id) do
    contribution
    |> Contribution.membership_changeset(membership_id)
    |> Repo.update()
  end

  @doc """
  Marks a contribution as completed with transaction reference.

  ## Examples

      iex> complete_contribution(contribution, transaction_reference)
      {:ok, %Contribution{}}

      iex> complete_contribution(contribution, bad_transaction_reference)
      {:error, %Ecto.Changeset{}}

  """
  def complete_contribution(contribution, transaction_reference) do
    contribution
    |> Contribution.complete_changeset(transaction_reference)
    |> Repo.update()
  end

  @doc """
  Marks a contribution as failed.

  ## Examples

      iex> fail_contribution(contribution)
      {:ok, %Contribution{}}

      iex> fail_contribution(contribution)
      {:error, %Ecto.Changeset{}}

  """
  def fail_contribution(contribution) do
    contribution
    |> Contribution.fail_changeset()
    |> Repo.update()
  end

  @doc """
  Gets a contribution by transaction reference.

  ## Examples

      iex> get_contribution_by_reference("txn_123")
      %Contribution{}

      iex> get_contribution_by_reference("txn_456")
      ** (Ecto.NoResultsError)

  """
  def get_contribution_by_reference(reference) do
    Repo.get_by(Contribution, transaction_reference: reference)
  end

  @doc """
  Gets a contribution by email (for pending membership payments).

  ## Examples

      iex> get_pending_contribution_by_email("user@example.com")
      %Contribution{}

      iex> get_pending_contribution_by_email("nonexistent@example.com")
      ** (Ecto.NoResultsError)

  """
  def get_pending_contribution_by_email(email) do
    Contribution
    |> where(email: ^email, status: "pending")
    |> where([c], is_nil(c.membership_id))
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Creates an M-Pesa transaction record from STK push response.

  ## Examples

      iex> create_mpesa_transaction(contribution_id, %{field: value})
      {:ok, %MpesaTransaction{}}

      iex> create_mpesa_transaction(contribution_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mpesa_transaction(contribution_id, attrs) do
    attrs
    |> Map.put("contribution_id", contribution_id)
    |> MpesaTransaction.stk_push_changeset()
    |> Repo.insert()
  end

  @doc """
  Gets an M-Pesa transaction by checkout request ID with preloaded contribution.

  ## Examples

      iex> get_mpesa_transaction_by_checkout_id("checkout_123")
      %MpesaTransaction{}

      iex> get_mpesa_transaction_by_checkout_id("checkout_456")
      ** (Ecto.NoResultsError)

  """
  def get_mpesa_transaction_by_checkout_id(checkout_request_id) do
    MpesaTransaction
    |> where(checkout_request_id: ^checkout_request_id)
    |> preload(:contribution)
    |> Repo.one()
  end

  @doc """
  Updates M-Pesa transaction with callback data.

  ## Examples

      iex> update_mpesa_transaction_callback(mpesa_transaction, %{field: new_value})
      {:ok, %MpesaTransaction{}}

      iex> update_mpesa_transaction_callback(mpesa_transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mpesa_transaction_callback(mpesa_transaction, attrs) do
    mpesa_transaction
    |> MpesaTransaction.callback_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Lists contributions for a membership.

  ## Examples

      iex> list_membership_contributions(membership_id)
      [%Contribution{}, ...]

  """
  def list_membership_contributions(membership_id) do
    Contribution
    |> where(membership_id: ^membership_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Updates a contribution.

  ## Examples

      iex> update_contribution(contribution, %{field: new_value})
      {:ok, %Contribution{}}

      iex> update_contribution(contribution, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contribution(%Contribution{} = contribution, attrs) do
    contribution
    |> Contribution.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contribution.

  ## Examples

      iex> delete_contribution(contribution)
      {:ok, %Contribution{}}

      iex> delete_contribution(contribution)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contribution(%Contribution{} = contribution) do
    Repo.delete(contribution)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contribution changes.

  ## Examples

      iex> change_contribution(contribution)
      %Ecto.Changeset{data: %Contribution{}}

  """
  def change_contribution(%Contribution{} = contribution, attrs \\ %{}) do
    Contribution.changeset(contribution, attrs)
  end
end
