defmodule TwentyDollarClub.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone_number, :string
    field :gender, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :phone_number, :gender])
    |> validate_required([:first_name, :last_name, :email, :phone_number, :gender])
  end
end
