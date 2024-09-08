defmodule PortalWeb.ClientSessionController do
  @moduledoc """
    handles the client session creation and deletion
  """
  use PortalWeb, :controller

  alias Portal.Clients
  alias PortalWeb.ClientAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "account has been created")
  end

  def create(conn, %{"_action" => "password-updated"} = params) do
    conn
    |> put_session(:client_return_to, ~p"/app/profile")
    |> create(params, "password updated successfully.")
  end

  # include the code for reset the password

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  # message is the flash message for the client.
  defp create(conn, %{"client" => client_params}, message) do
    %{"email" => email, "password" => password} = client_params

    if client = Clients.get_client_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, message)
      |> ClientAuth.log_in_client(client, client_params)
    else
      conn
      |> put_flash(:error, "invalid credentials")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/app/login")
    end
  end

  @doc """
    log out the client and clear the session.
  """
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "account created successfully")
    |> ClientAuth.log_out_client()
  end
end
