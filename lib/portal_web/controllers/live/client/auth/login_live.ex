defmodule PortalWeb.AuthClients.LoginLive do
  @moduledoc """
  login for companies
  does not include the server side validation for forms. since that
  might not be needed.

  consider adding a JS script that we can use to avoid invalid calls.

  """

  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "client")
    {:ok, assign(socket, form: form, title: "login for client"), temporary_assigns: [form: form]}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @title %></h1>
      <.simple_form for={@form} id="login_form" action={~p"/app/login"} phx-update="ingore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/app/recover"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">login now</.button>
        </:actions>
      </.simple_form>

      <div class="py-10">
        <a href="/app/register">create an account now </a>
      </div>
    </div>
    """
  end
end
