defmodule PortalWeb.ClientLive.JobsLive do
  @moduledoc """
  profile page for clients.
  they can set up their profile along with
  """

  use PortalWeb, :live_view_client

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    details of the jobs for the client
    """
  end
end
