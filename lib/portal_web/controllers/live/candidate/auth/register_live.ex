defmodule PortalWeb.AuthCandidate.RegisterLive do
  @moduledoc """
    will render a list of trending jobs
  """

  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <span class="text-4xl py-32 text-center block ">
      page for creating a candidate account
    </span>
    """
  end
end
