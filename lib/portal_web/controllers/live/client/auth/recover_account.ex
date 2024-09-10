defmodule PortalWeb.AuthClients.RecoverAccountLive do
  @moduledoc """
  recover account for companies
  named as a generic because will include some general
  methods to recover the account
  """

  use PortalWeb, :live_view_auth
  import PortalWeb.UI.Button

  alias Portal.Clients

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(form: to_form(%{}, as: "client"))
     |> assign(:title, "Recover your account")}
  end

  def render(assigns) do
    ~H"""
    <div class=" max-w-md mx-auto  px-3 md:w-11/12">
      <span class="text-2xl text-center px-4 block font-semibold text-brand"><%= @title %></span>
      <span class="text-sm font-normal block w-10/12 mx-auto text-center pt-3">
        We will send an email with instructions to recover your account to your inbox.
      </span>
      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="example@gmail.com" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Send recovery instructions
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center pt-4 text-sm mt-4">
        <.link href={~p"/app/register"} class="text-base font-medium text-inherit underline-offset-4">
          Register
        </.link>
        <span class="px-3">|</span>
        <.link class="text-base font-medium text-inherit underline-offset-4" href={~p"/app/login"}>
          Log in
        </.link>
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
