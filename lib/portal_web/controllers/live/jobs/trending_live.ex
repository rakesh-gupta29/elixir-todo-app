defmodule PortalWeb.Live.Jobs.TrendingLive do
  @moduledoc """
    will render a list of trending jobs
  """

  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <span>will render a list of trending jobs here</span>
    """
  end
end
