defmodule TwentyDollarClub.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :hashed_password, :string
    field :phone_number, :string
    field :gender, :string
    has_one :membership, TwentyDollarClub.Memberships.Membership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :hashed_password, :phone_number, :gender])
    |> validate_required([
      :first_name,
      :last_name,
      :email,
      :hashed_password,
      :phone_number,
      :gender
    ])
    |> unique_constraint(:email)
    |> unique_constraint(:phone_number)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> put_hashed_password()
  end

  defp put_hashed_password(
         %Ecto.Changeset{valid?: true, changes: %{hashed_password: hashed_password}} = changeset
       ) do
    change(changeset, hashed_password: Pbkdf2.hash_pwd_salt(hashed_password))
  end

  defp put_hashed_password(changeset), do: changeset
end
