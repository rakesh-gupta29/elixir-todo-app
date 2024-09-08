defmodule PortalWeb.ClientLive.ProfileLive do
  @moduledoc """
  login for companies
  """
  alias Portal.Clients

  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    client = socket.assigns.current_client
    password_changeset = Clients.change_client_password(client)

    {:ok,
     socket
     |> assign(:title, "update the profile settings here ")
     |> assign(:current_email, client.email)
     |> assign(:password_form, to_form(password_changeset))
     |> assign(:trigger_submit, false)
     |> assign(:current_password, nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-md mx-auto px-3  md:w-11/12 ">
      <h1><%= @title %></h1>
      <.simple_form
        for={@password_form}
        id="password_update_form"
        phx-submit="update-password"
        phx-change="validate-password"
        phx-trigger-action={@trigger_submit}
        action={~p"/app/login?_action=password-updated"}
        method="post"
      >
        <%!-- include a hidden field for email too. that is required while logging in again. --%>
        <input
          name={@password_form[:email].name}
          type="hidden"
          id="hidden_check_email"
          value={@current_email}
        />
        <.input field={@password_form[:password]} type="password" label="New password" required />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
        />
        <.input
          field={@password_form[:current_password]}
          name="current_password"
          type="password"
          label="Current password"
          id="current_password_for_password"
          value={@current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing...">Update Password</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  # make sure to define the current password while mounting the view.
  def handle_event("validate-password", params, socket) do
    %{"current_password" => current_password, "client" => client_params} = params

    form =
      socket.assigns.current_client
      |> Clients.change_client_password(client_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: form, current_password: current_password)}
  end

  def handle_event("update-password", params, socket) do
    %{"current_password" => current_password, "client" => client_params} = params

    {:noreply, socket}
    # client = socket.assigns.current_client
    # updates the password with the validation of current password
    # return :ok or :error
    client = socket.assigns.current_client

    case Clients.update_client_password(client, current_password, client_params) do
      {:ok, client} ->
        password_form =
          client
          |> Clients.change_client_password(client_params)
          |> to_form()

        {:noreply, assign(socket, password_form: password_form, trigger_submit: true)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
