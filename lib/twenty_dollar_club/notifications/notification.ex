defmodule TwentyDollarClub.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :event, :string
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
end
