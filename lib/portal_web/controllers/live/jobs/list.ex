defmodule PortalWeb.JobsLive.ListJobs do
  @moduledoc """
  this page will list all the jobs.
  will include the details filter along with search to get the matching list
  """
  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(withLayout: false)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <span>check the jobs listing page </span>
    </div>
    """
  end
end
