defmodule Portal.Clients do
  @moduledoc """
    context for clients
  """
  import Ecto.Query, warn: false

  alias Portal.Repo

  alias Portal.Clients.Client

  # authentication
  def create_client_account_changeset(%Client{} = client, attrs \\ %{}) do
    Client.registration_changeset(client, attrs, hash_password: false, validate_email: false)
  end

  def register_client(attrs) do
    %Client{}
    |> Client.registration_changeset(attrs)
    |> Repo.insert()
  end
end
