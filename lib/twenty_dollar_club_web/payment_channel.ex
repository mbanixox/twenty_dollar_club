defmodule TwentyDollarClubWeb.PaymentChannel do
  use TwentyDollarClubWeb, :channel

  alias TwentyDollarClub.Users

  @impl true
  def join("payment:" <> email, _payload, socket) do
    # Subscribe to PubSub topic for this email
    Phoenix.PubSub.subscribe(TwentyDollarClub.PubSub, "payment:#{email}")

    {:ok, assign(socket, :email, email)}
  end

  @impl true
  def handle_info({:membership_created, %{user_id: user_id}}, socket) do
    # Generate new token with membership claims
    user = Users.get_user_with_membership!(user_id)

    case TwentyDollarClubWeb.Auth.Guardian.encode_and_sign(user) do
      {:ok, token, _claims} ->
        push(socket, "membership_created", %{
          token: token,
          user: %{
            id: user.id,
            email: user.email,
            first_name: user.first_name,
            last_name: user.last_name,
            membership: %{
              id: user.membership.id,
              generated_id: user.membership.generated_id,
              role: user.membership.role
            }
          }
        })

      {:error, _reason} ->
        push(socket, "error", %{message: "Failed to generate token"})
    end

    {:noreply, socket}
  end
end
