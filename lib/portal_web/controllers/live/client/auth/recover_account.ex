defmodule PortalWeb.AuthClients.RecoverAccountLive do
  @moduledoc """
  recover account for companies
  named as a generic because will include some general
  methods to recover the account
  """

  use PortalWeb, :live_view

  alias Portal.Clients

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "client"))}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-lg py-20 mx-auto md:w-11/12 px-3 ">
      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"/app/register"}>Register</.link> | <.link href={~p"/app/login"}>Log in</.link>
      </p>
    </div>
    """
  end

  def handle_event("send_email", params, socket) do
    %{"client" => %{"email" => email}} = params

    if client = Clients.get_client_by_email(email) do
      Clients.deliver_email_for_password_reset(
        client,
        &url(~p"/app/recover/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)}
  end
end
