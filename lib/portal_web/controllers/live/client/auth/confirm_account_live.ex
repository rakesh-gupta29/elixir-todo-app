defmodule PortalWeb.AuthClients.ClientConfirmationInstructionsLive do
  @moduledoc """
  recover account for companies
  named as a generic because will include some general
  methods to recover the account
  """

  use PortalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:title, "page without the token - company ")}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1><%= @title %></h1>
    </div>
    """
  end
end
