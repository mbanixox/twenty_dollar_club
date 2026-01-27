defmodule TwentyDollarClub.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :event, Ecto.Enum,
      values: [
        :new_project_created,
        :project_updated,
        :project_deleted,
        :pending_project_contribution,
        :contribution_received,
        :beneficiary_added,
        :pending_membership_approval
      ]

    field :message, :string
    field :read, :boolean, default: false
    field :severity, Ecto.Enum, values: [:low, :medium, :high, :critical]
    field :resource_type, Ecto.Enum, values: [:project, :beneficiary, :contribution, :membership]
    field :recipient_type, Ecto.Enum, values: [:member, :admin, :super_admin]
    belongs_to :membership, TwentyDollarClub.Memberships.Membership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:event, :message, :read, :severity, :recipient_type, :resource_type])
    |> validate_required([:event, :message, :read, :severity, :recipient_type, :resource_type])
  end

  def read_changeset(notification, attrs) do
    notification
    |> cast(attrs, [:read])
    |> validate_required([:read])
  end
end
