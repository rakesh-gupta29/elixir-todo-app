defmodule PortalWeb.AuthClients.ClientConfirmationLive do
  @moduledoc """
  recover account for companies
  named as a generic because will include some general
  methods to recover the account
  """

  use PortalWeb, :live_view
  import PortalWeb.UI.Button

  alias Portal.Clients

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "client")
    {:ok, assign(socket, form: form, title: "confirm the email"), temporary_assigns: [form: nil]}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-screen-sm px-6 mx-auto py-10">
      <h1><%= @title %></h1>

      <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <:actions>
          <.button phx-disable-with="Confirming..." class="w-full">Confirm my account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  # Do not log in the client after confirmation to avoid a
  # leaked token giving the check access to the account.
  def handle_event("confirm_account", %{"client" => %{"token" => token}}, socket) do
    case Clients.confirm_client(token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "confirmation done")
         |> redirect(to: ~p"/app")}

      :error ->
        # if the account is already confirmed then is is quite possible
        # the link inside the email was already visited.
        # we can the redirect the user without a warning.
        case socket.assigns do
          %{current_client: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply,
             socket
             |> put_flash(:info, "account confirmation is already done")
             |> redirect(to: ~p"/app")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "either link is expired or invalid. Please regerate the link")
             |> redirect(to: ~p"/app")}
        end
    end
  end
end
