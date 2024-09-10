defmodule PortalWeb.ClientLive.SettingLive do
  @moduledoc """
    update the profile details
  """

  use PortalWeb, :live_view_client

  def mount(_params, _session, socket) do
    client = socket.assigns.current_client

    {:ok, socket |> assign(:view_mode, false) |> assign(:client, client)}
  end

  def handle_event("toggle-mode", _params, socket) do
    mode = socket.assigns.view_mode
    {:noreply, socket |> assign(:view_mode, !mode)}
  end

  def render(assigns) do
    ~H"""
    <div class="w-container pt-16 pb-10 ">
      <%= if @view_mode do %>
        view mode
      <% else %>
        <%= @client.email %>
      <% end %>
    </div>
    """
  end
end
