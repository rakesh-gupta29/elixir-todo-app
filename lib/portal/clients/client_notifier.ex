defmodule Portal.Clients.ClientNotifier do
  @moduledoc """
    notifier for client module
    used for sending emails and later on, notifications.
  """
  import Swoosh.Email

  alias Portal.Mailer

  # utility function for sending the email using applications' mailer utility
  defp deliver_through_email(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"portal_app", "example@gmail.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_confirmation_instructions(client, url) do
    deliver_through_email(client.email, "Confirmation instructions", """

    ==============================

    Hi #{client.email},

    You can confirm your account by visiting the URL below:

    <a href=" #{url}"> #{url}</a>

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a client's password.
  """
  def deliver_reset_password_instructions(client, url) do
    IO.inspect("delivering the email now")

    deliver_through_email(client.email, "Reset password instructions", """

    ==============================

    Hi #{client.email},

    You can reset your password by visiting the URL below:

    <a href=" #{url}"> #{url}</a>

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
