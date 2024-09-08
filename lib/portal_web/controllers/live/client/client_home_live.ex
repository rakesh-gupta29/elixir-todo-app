defmodule PortalWeb.ClientLive.HomeLive do
  @moduledoc """
  login for companies
  """

  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:title, "homepage of the client")}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @current_client.email %></h1>
      <h1><%= @current_client.confirmed_at %></h1>

      <%= if @current_client.is_verified do %>
        <p>true</p>
      <% else %>
        <p>false</p>
      <% end %>

      <button type="button" class="test-btn" phx-click="send-confirmation-email">
        send the email to confirm the account
      </button>

      <.link href={~p"/app/profile"}>
        profile page
      </.link>
      <h1><%= @title %></h1>
    </div>
    """
  end

  @doc """
   uses deliver_email_for_account_confirmation which will either return
    {:ok, email } or {:error, :already_confirmed}
  """
  def handle_event("send-confirmation-email", _params, socket) do
    case Portal.Clients.deliver_email_for_account_confirmation(
           socket.assigns.current_client,
           &url(~p"/app/confirm/#{&1}")
         ) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "will be done ")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "account confirmation is already done ")}
    end
  end
end
