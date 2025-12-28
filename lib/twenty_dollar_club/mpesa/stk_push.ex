defmodule TwentyDollarClub.Mpesa.StkPush do
  alias TwentyDollarClub.Mpesa.{MpesaClient, Utils}

  def push(phone, amount, reference) do
    config = Application.get_env(:twenty_dollar_club, :mpesa)
    timestamp = Utils.current_timestamp()

    body = %{
      "BusinessShortCode" => config[:shortcode],
      "Password" => Utils.password(config[:shortcode], config[:passkey], timestamp),
      "Timestamp" => timestamp,
      "TransactionType" => "CustomerPayBillOnline",
      "Amount" => amount,
      "PartyA" => phone,
      "PartyB" => config[:shortcode],
      "PhoneNumber" => phone,
      "CallBackURL" => config[:callback_url],
      "AccountReference" => reference,
      "TransactionDesc" => "Payment of #{reference}"
    }

    MpesaClient.post("#{config[:base_url]}/mpesa/stkpush/v1/processrequest", body)
  end
end
