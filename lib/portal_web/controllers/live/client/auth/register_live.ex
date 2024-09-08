defmodule PortalWeb.AuthClients.RegisterLive do
  @moduledoc """
  register for companies
  """

  use PortalWeb, :live_view

  alias Portal.Clients.Client
  alias Portal.Clients

  def mount(_params, _session, socket) do
    changeset = Clients.create_client_account_changeset(%Client{})

    {:ok,
     socket
     |> assign(:title, "register - company ")
     |> assign(trigger_submit: false, check_errors: false)
     |> assign_form(changeset)}
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset, as: "client")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def handle_event("validate", %{"client" => client_params}, socket) do
    changeset = Clients.create_client_account_changeset(%Client{}, client_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"client" => client_params}, socket) do
    case Clients.register_client(client_params) do
      {:ok, client} ->
        {:ok, _} =
          Clients.deliver_email_for_account_confirmation(
            client,
            &url(~p"/app/confirm/#{&1}")
          )

        changeset = Clients.create_client_account_changeset(client)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  # triggers the save event which creates the user
  # then a post req is made to the /login path which will
  # login the user.

  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @title %></h1>
      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/app/login?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:name]} type="text" label="Name" required />
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>

      <div class="py-10">
        <a href="/app/login">have an account</a>
      </div>
    </div>
    """
  end
end
