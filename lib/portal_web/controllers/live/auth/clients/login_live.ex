defmodule PortalWeb.AuthClients.LoginLive do
  @moduledoc """
  register for companies
  """

  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:title, "login - company ")}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @title %></h1>
    </div>
    """
  end
end
