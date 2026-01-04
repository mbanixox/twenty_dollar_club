defmodule TwentyDollarClub.Contributions.Contribution do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contributions" do
    field :transaction_reference, :string
    field :payment_method, Ecto.Enum, values: [:mpesa, :card, :cash]
    field :amount, :decimal
    field :status, Ecto.Enum, values: [:pending, :completed, :failed, :cancelled], default: :pending
    field :description, :string
    field :phone_number, :string
    field :email, :string
    field :contribution_type, Ecto.Enum, values: [:membership, :project], default: :membership

    belongs_to :membership, TwentyDollarClub.Memberships.Membership
    belongs_to :project, TwentyDollarClub.Projects.Project
    has_one :mpesa_transaction, TwentyDollarClub.Contributions.MpesaTransaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contribution, attrs) do
    contribution
    |> cast(attrs, [:transaction_reference, :payment_method, :amount, :status, :description, :phone_number, :email])
    |> validate_required([:payment_method, :amount])
    |> validate_number(:amount, greater_than: 0)
    |> unique_constraint(:transaction_reference)
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:payment_method, :amount, :description, :phone_number, :email, :contribution_type])
    |> validate_required([:payment_method, :amount, :email, :contribution_type])
    |> validate_number(:amount, greater_than: 0)
    |> put_change(:status, :pending)
  end

  def complete_changeset(contribution, transaction_reference) do
    contribution
    |> cast(%{}, [])
    |> put_change(:status, :completed)
    |> put_change(:transaction_reference, transaction_reference)
    |> validate_required([:transaction_reference])
  end

  def fail_changeset(contribution) do
    contribution
    |> cast(%{}, [])
    |> put_change(:status, :failed)
  end

  def membership_changeset(contribution, membership_id) do
    contribution
    |> cast(%{}, [])
    |> put_change(:membership_id, membership_id)
  end

  def project_changeset(contribution, project_id) do
    contribution
    |> cast(%{}, [])
    |> put_change(:project_id, project_id)
  end
end
