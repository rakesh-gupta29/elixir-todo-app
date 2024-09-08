defmodule Portal.Clients.ClientToken do
  @moduledoc """
    context for handling the clients_token
    dependent on the clients table.
    used to manage the session
  """
  use Ecto.Schema
  import Ecto.Query
  alias Portal.Clients.ClientToken

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  # @reset_password_validity_in_days 1
  # @confirm_validity_in_days 7
  @session_validity_in_days 60
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7

  schema "clients_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    # will be referring to the field of client_id
    belongs_to :client, Portal.Clients.Client

    timestamps(type: :utc_datetime, updated_at: false)
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual client
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(client) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %ClientToken{token: token, context: "session", client_id: client.id}}
  end

  @doc """
    builds a token and delivers to client's email

  The non-hashed token is sent to the client email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  We  can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(client, context) do
    build_hashed_token(client, context, client.email)
  end

  def build_hashed_token(client, context, receiver) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %ClientToken{
       token: hashed_token,
       context: context,
       sent_to: receiver,
       client_id: client.id
     }}
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  def by_token_and_context_query(token, context) do
    from ClientToken, where: [token: ^token, context: ^context]
  end

  def by_client_and_context_query(client, :all) do
    from t in ClientToken, where: t.client_id == ^client.id
  end

  def by_client_and_context_query(client, [_ | _] = contexts) do
    from t in ClientToken, where: t.client_id == ^client.id and t.context in ^contexts
  end

  @doc """
  checks if the token is valid and returns the underlying lookup query
  token is valid is it is in the database and has not expired.

  query will be returning the underlying client, if any
  """
  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: client in assoc(token, :client),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: client

    {:ok, query}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the client found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: client in assoc(token, :client),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == client.email,
            select: client

        {:ok, query}

      :error ->
        :error
    end
  end
end
