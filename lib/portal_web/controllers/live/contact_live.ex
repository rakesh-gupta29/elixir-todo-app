defmodule PortalWeb.Live.ContactLive do
  @moduledoc """
    module for the contact us page
  """

  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <span>
      welcome from contact us page
    </span>
    """
  end
end
