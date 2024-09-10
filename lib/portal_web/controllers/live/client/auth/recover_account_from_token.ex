defmodule PortalWeb.AuthClients.RecoverAccountFromTokenLive do
  @moduledoc """
  recover account for companies
  named as a generic because will include some general
  methods to recover the account
  """

  use PortalWeb, :live_view_auth
  import PortalWeb.UI.Button

  alias Portal.Clients

  def mount(params, _session, socket) do
    socket = assign_client_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{client: client} ->
          # returns a changeset for the form
          Clients.change_client_password(client)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  def handle_event("validate", %{"client" => client_params}, socket) do
    changeset = Clients.change_client_password(socket.assigns.client, client_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  # do not login the client after reset password.
  # to avoid the leaked token error.
  def handle_event("reset_password_from_token", %{"client" => client_params}, socket) do
    case Clients.reset_client_password(socket.assigns.client, client_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "password reset successfully")
         |> redirect(to: ~p"/app/login")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "client"))
  end

  def assign_client_and_token(socket, %{"token" => token}) do
    if client = Clients.get_client_by_reset_password_token(token) do
      assign(socket, client: client, token: token)
    else
      socket
      |> put_flash(:error, "link is invalid or expired")
      |> redirect(to: ~p"/")
    end
  end

  def render(assigns) do
    ~H"""
    <div class=" max-w-md mx-auto  px-3 md:w-11/12">
      <span class="text-2xl text-center px-4 block font-semibold text-brand">
        Reset your password here
      </span>
      <.simple_form
        for={@form}
        id="recover_account_from_password"
        phx-submit="reset_password_from_token"
        phx-change="validate"
      >
        <.error :if={@form.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input
          field={@form[:password]}
          type="password"
          placeholder="*********"
          label="New password"
          required
        />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm new password"
          required
          placeholder="*********"
        />
        <:actions>
          <.button phx-disable-with="Resetting..." class="w-full">Update account password</.button>
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
end
