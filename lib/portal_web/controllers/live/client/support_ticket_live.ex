defmodule PortalWeb.ClientLive.SupportTicketLive do
  @moduledoc """
  login for companies
  """

  use PortalWeb, :live_view_client

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:title, "homepage of the client")}
  end

  def render(assigns) do
    ~H"""
    <div>
      support ticket
    </div>
    """
  end
end
