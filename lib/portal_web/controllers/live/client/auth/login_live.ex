defmodule PortalWeb.AuthClients.LoginLive do
  @moduledoc """
  login for companies
  does not include the server side validation for forms. since that
  might not be needed.

  consider adding a JS script that we can use to avoid invalid calls.

  """

  use PortalWeb, :live_view_auth
  import PortalWeb.UI.Button

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "client")
    {:ok, assign(socket, form: form, title: "Welcome back"), temporary_assigns: [form: form]}
  end

  def render(assigns) do
    ~H"""
    <div class=" max-w-md mx-auto  px-3 md:w-11/12">
      <span class="text-2xl text-center px-4 block font-semibold text-brand"><%= @title %></span>
      <.simple_form for={@form} id="login_form" action={~p"/app/login"} phx-update="ingore">
        <.input
          placeholder="example@gamil.com"
          field={@form[:email]}
          type="email"
          label="Email"
          required
        />
        <.input
          placeholder="******"
          field={@form[:password]}
          type="password"
          label="Password"
          required
        />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/app/recover"} class="text-sm font-medium text-inherit underline-offset-4">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <div class="pt-6 grid w-full">
            <.button phx-disable-with="Creating account..." class="w-full">Log in</.button>
          </div>
        </:actions>
      </.simple_form>

      <div class="py-6 text-center">
        <span>
          Create an account now.
          <a
            href="/app/register"
            class=" text-inherit underline font-semibold px-2 underline-offset-4 decoration-from-font"
          >
            Register now
          </a>
        </span>
      </div>

      <div class="text-center pb-4">
        <span class="text-sm">
          By continuing, you agree to our <br />
          <a
            href="/terms-and-conditions#terms"
            class=" text-inherit underline font-normal px-2 underline-offset-4 decoration-from-font hover:text-brand"
          >
            Terms of services
          </a>
          and
          <a
            href="/terms-and-conditions#privacy"
            class=" text-inherit underline font-normal px-2 underline-offset-4 decoration-from-font hover:text-brand"
          >
            Privacy policies
          </a>
        </span>
      </div>
    </div>
    """
  end
end
