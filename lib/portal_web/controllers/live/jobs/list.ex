defmodule PortalWeb.JobsLive.ApplyOnJob do
  @moduledoc """
  this page will list all the jobs.
  will include the details filter along with search to get the matching list
  """
  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <span>check the jobs listing page </span>
    </div>
    """
  end
end
