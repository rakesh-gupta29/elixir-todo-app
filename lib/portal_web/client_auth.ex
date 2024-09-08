defmodule PortalWeb.ClientAuth do
  @moduledoc """
    context for handling the authentication feature of the client.
  """
  use PortalWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Portal.Clients

  # Make the "remember me" cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in ClientToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_portal_web_client_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the client in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """

  def log_in_client(conn, client, params \\ %{}) do
    token = Clients.generate_client_session_token(client)
    client_return_to = get_session(conn, :client_return_to)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    # will allow us to persist the user through cookies
    # expects a remember_me key from the client before saving
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: client_return_to || signed_in_path(conn))
  end

  @doc """
  logs out the client and clears the session
  """
  def log_out_client(conn) do
    client_token = get_session(conn, :client_token)

    client_token && Clients.delete_client_session_token(client_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      PortalWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/")
  end

  @doc """
    fetches the current client from the session cookies
    generally the output will be used in the live view
  """
  def fetch_current_client(conn, _opts) do
    {client_token, conn} = ensure_client_token(conn)
    client = client_token && Clients.get_client_by_session_token(client_token)
    assign(conn, :current_client, client)
  end

  @doc """
    Handles exposing the value of current_client to liveviews.
    above function is for exposing the current_client value to conn and not the socket.

    ## Options

    * `:mount_current_client` -  assigns current_client on the basis of token.
    nil if there is no token or no matching client

    * `:ensure_authenticated` - authenticates the clients from the tokens table
      Redirects to the login page if there is no Client.

    * `redirect_if_client_is_authenticated` -  Authenticates the client from session.
    if there is one, will be redirected to the signed in path.


    ## Examples
    - add the methods here on how we can invoke this method or assign the value
    of the current client to the session.
  """
  def require_authenticated_client(conn, _opts) do
    if conn.assigns[:current_client] do
      conn
    else
      conn
      |> put_flash(:error, "Please log in to access this page")
      |> maybe_preserve_return_to_path()
      |> redirect(to: signed_out_path(conn))
      |> halt()
    end
  end

  # hooks for using the plugs. called in the live_session macro chain.
  def on_mount(:mount_current_client, _params, session, socket) do
    {:cont, mount_current_client(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_client(socket, session)

    if socket.assigns.current_client do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/app/login")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_client_is_authenticated, _params, session, socket) do
    socket = mount_current_client(socket, session)

    if socket.assigns.current_client do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp mount_current_client(socket, session) do
    Phoenix.Component.assign_new(socket, :current_client, fn ->
      if client_token = session["client_token"] do
        Clients.get_client_by_session_token(client_token)
      end
    end)
  end

  # preserves the current path in session so that we can redirect
  # after the authentication is done
  defp maybe_preserve_return_to_path(%{method: "GET"} = conn) do
    put_session(conn, :client_return_to, current_path(conn))
  end

  defp maybe_preserve_return_to_path(conn), do: conn

  def redirect_if_client_is_authenticated(conn, _opts) do
    if conn.assigns[:current_client] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  # Helper functions
  # ensures that the token exists in session or cookie. otherwise, returns nil
  defp ensure_client_token(conn) do
    if token = get_session(conn, :client_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token_from_cookie = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token_from_cookie)}
      else
        {nil, conn}
      end
    end
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #

  # might consider adding something in here. see docs above.
  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)

    # what all other things happen when the this func is called.
    |> clear_session()
  end

  # puts the token into the client and the live socket id
  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:client_token, token)
    |> put_session(:live_socket_id, "clients_sessions:#{Base.url_encode64(token)}")
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  # right now, putting the cookie in all the cases.
  defp maybe_write_remember_me_cookie(conn, token, _params) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp signed_in_path(_conn), do: ~p"/app"

  defp signed_out_path(_conn), do: ~p"/app/login"
end
