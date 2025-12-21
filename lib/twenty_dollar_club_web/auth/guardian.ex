defmodule TwentyDollarClubWeb.Auth.Guardian do
  @moduledoc """
  Guardian implementation.

  This module implements the required Guardian behaviour for user
  authentication using JWT tokens. It defines how to encode and
  decode user resources to and from JWT claims, as well as helper
  functions for authenticating users.

  """

  use Guardian, otp_app: :twenty_dollar_club

  alias TwentyDollarClub.Users
  alias TwentyDollarClubWeb.Auth.ErrorResponse

  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :no_id_provided}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Users.get_user!(id) do
      nil ->
        {:error, :not_found}

      resource ->
        {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_id_provided}
  end

  def authenticate(email, password) do
    case Users.get_user_by_email(email) do
      nil ->
        {:error, :unauthorized}

      user ->
        case validate_password(password, user.hashed_password) do
          true -> create_token(user)
          false -> {:error, :unauthorized}
        end
    end
  end

  def authenticate(token) do
    with {:ok, claims} <- decode_and_verify(token),
         {:ok, user} <- resource_from_claims(claims),
         {:ok, _old, {new_token, _new_claims}} = refresh(token) do
      {:ok, user, new_token}
    else
      {:error, _message} -> raise ErrorResponse.NotFound
    end
  end

  defp validate_password(password, hashed_password) do
    Pbkdf2.verify_pass(password, hashed_password)
  end

  defp create_token(user) do
    {:ok, token, _claims} = encode_and_sign(user)
    {:ok, user, token}
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
