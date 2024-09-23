defmodule Portal.Clients do
  @moduledoc """
    context for clients
  """
  import Ecto.Query, warn: false

  alias Portal.Repo

  alias Portal.Clients.Client
  alias Portal.Client.SocialProfile

  alias Portal.Clients.ClientToken
  alias Portal.Clients.ClientNotifier
  alias Portal.Client.Location

  # authentication
  def create_client_account_changeset(%Client{} = client, attrs \\ %{}) do
    Client.registration_changeset(client, attrs, hash_password: false, validate_email: false)
  end

  def register_client(attrs) do
    %Client{}
    |> Client.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_client_password(client, attrs \\ %{}) do
    Client.password_changeset(client, attrs, hash_password: true)
  end

  def update_profile_basics_changeset(client, attrs \\ %{}) do
    Client.basic_profile_changeset(client, attrs)
  end

  def update_profile_basics(%Client{} = client, params) do
    client
    |> Client.basic_profile_changeset(params)
    |> Repo.update()
  end

  @doc """
  Resets the client password.
  Not responsible for checking that the old password of
  client is right or not.


  ## Examples

      iex> reset_client_password(client, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Client{}}

      iex> reset_client_password(client, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """

  def reset_client_password(client, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:client, Client.password_changeset(client, attrs))
    |> Ecto.Multi.delete_all(:tokens, ClientToken.by_client_and_context_query(client, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{client: client}} -> {:ok, client}
      {:error, :client, changeset, _} -> {:error, changeset}
    end
  end

  def update_client_password(client, current_password, attrs) do
    changeset =
      client
      |> Client.password_changeset(attrs)
      |> Client.validate_current_password_for_user(current_password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:client, changeset)
    |> Ecto.Multi.delete_all(:tokens, ClientToken.by_client_and_context_query(client, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{client: client}} -> {:ok, client}
      {:error, :client, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
    confirms a client account with the given token

    if the token matches then the client account is marked
    as confirmed and the token is deleted.
  """

  def confirm_client(token) do
    with {:ok, query} <- ClientToken.verify_email_token_query(token, "confirm"),
         %Client{} = client <- Repo.one(query),
         {:ok, %{client: client}} <- Repo.transaction(confirm_client_multi(client)) do
      {:ok, client}
    else
      _ ->
        :error
    end
  end

  @doc """
  Gets a client by email and password.

  ## Examples

      iex> get_client_by_email_and_password("foo@example.com", "correct_password")
      %Client{}

      iex> get_client_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_client_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    client = Repo.get_by(Client, email: email)
    if Client.valid_password_for_user?(client, password), do: client
  end

  @doc """
  Gets a client by email.
  used to check that the email exists or not.
  """
  def get_client_by_email(email) when is_binary(email) do
    Repo.get_by(Client, email: email)
  end

  @doc """
  gets the client with given signed token
  """
  def get_client_by_session_token(token) do
    {:ok, query} = ClientToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
    get a client by reset password token
      ## Examples

      iex> get_client_by_reset_password_token("validtoken")
      %Client{}

      iex> get_client_by_reset_password_token("invalidtoken")
      nil

  """
  def get_client_by_reset_password_token(token) do
    with {:ok, query} <- ClientToken.verify_email_token_query(token, "reset_password"),
         %Client{} = client <- Repo.one(query) do
      client
    else
      _ -> nil
    end
  end

  @doc """
  Generates a session token.
  """
  def generate_client_session_token(client) do
    {token, client_token} = ClientToken.build_session_token(client)
    # it will automatically refer to the table that it has to insert info
    # by the schema that is being passed.
    Repo.insert!(client_token)
    token
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_client_session_token(token) do
    Repo.delete_all(ClientToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
    delivers the email with the instructions to confirm the account
  """

  def deliver_email_for_account_confirmation(%Client{} = client, confirmation_url_function)
      when is_function(confirmation_url_function, 1) do
    if client.confirmed_at do
      {:error, :already_confirmed}
    else
      # token is just generated and returned. which needs to be inserted in the db manually here.
      # encoded token is given to the client and client_token is inserted in the db
      {encoded_token, client_token} = ClientToken.build_email_token(client, "confirm")
      Repo.insert(client_token)

      ClientNotifier.deliver_confirmation_instructions(
        client,
        confirmation_url_function.(encoded_token)
      )
    end
  end

  @doc """
    delivers the email with the instructions to reset the password
  """

  def deliver_email_for_password_reset(%Client{} = client, reset_password_url_function)
      when is_function(reset_password_url_function) do
    {encoded_token, client_token} = ClientToken.build_email_token(client, "reset_password")

    Repo.insert!(client_token)

    ClientNotifier.deliver_reset_password_instructions(
      client,
      reset_password_url_function.(encoded_token)
    )
  end

  def confirm_client_multi(client) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:client, Client.confirm_client_changeset(client))
    |> Ecto.Multi.delete_all(
      :tokens,
      ClientToken.by_client_and_context_query(client, ["confirm"])
    )
  end

  @doc """
  Takes the item for social profile and then adds it to the list of profiles for the client.
  """
  def add_client_social_profile(client, profile_item) do
    # Create a new changeset for the incoming profile_item
    new_profile_changeset = SocialProfile.changeset(%SocialProfile{}, profile_item)

    # why do we need to change this to map here. like a list of structs to a map
    if new_profile_changeset.valid? do
      # Fetch the existing social profiles and append the new one
      updated_profiles =
        Enum.map(client.social_profiles, &Map.from_struct(&1)) ++
          [Ecto.Changeset.apply_changes(new_profile_changeset)]

      # Create a changeset to update the social profiles field of the client
      client_changeset =
        client
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_embed(:social_profiles, updated_profiles)

      # Try to update the client with the new list of social profiles
      case Repo.update(client_changeset) do
        {:ok, updated_client} -> {:ok, updated_client}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, new_profile_changeset}
    end
  end

  @doc """
    Updates an existing social profile in the client's list of social profiles.
  """
  def update_client_social_profile(client, profile_item) do
    profile_id = profile_item["id"] || profile_item[:id]

    existing_profile =
      Enum.find(client.social_profiles, fn profile -> profile.id == profile_id end)

    if existing_profile do
      updated_profile_changeset = SocialProfile.changeset(existing_profile, profile_item)

      if updated_profile_changeset.valid? do
        updated_profile = Ecto.Changeset.apply_changes(updated_profile_changeset)

        updated_profiles =
          Enum.map(client.social_profiles, fn profile ->
            if profile.id == existing_profile.id do
              updated_profile
            else
              profile
            end
          end)

        updated_profiles_map = Enum.map(updated_profiles, &Map.from_struct/1)

        client_changeset =
          client
          |> Ecto.Changeset.change(%{social_profiles: updated_profiles_map})
          |> Client.social_profiles_changeset(%{social_profiles: updated_profiles_map})

        case Repo.update(client_changeset) do
          {:ok, updated_client} -> {:ok, updated_client}
          {:error, changeset} -> {:error, changeset}
        end
      else
        {:error, updated_profile_changeset}
      end
    else
      {:error, :social_profile_not_found}
    end
  end

  @doc """
    Deletes a social profile from the client's list of social profiles.
  """
  def delete_social_profile(client, profile_id) do
    existing_profile =
      Enum.find(client.social_profiles, fn profile -> profile.id == profile_id end)

    if existing_profile do
      updated_profiles =
        Enum.filter(client.social_profiles, fn profile -> profile.id != profile_id end)

      updated_profiles_map = Enum.map(updated_profiles, &Map.from_struct/1)

      client_changeset =
        client
        |> Ecto.Changeset.change(%{social_profiles: updated_profiles_map})
        |> Client.social_profiles_changeset(%{social_profiles: updated_profiles_map})

      case Repo.update(client_changeset) do
        {:ok, updated_client} -> {:ok, updated_client}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, :social_profile_not_found}
    end
  end

  # ===================================================== Locations ============================================================

  def add_location(client, item) do
    new_locations_changeset = Location.changeset(%Location{}, item)

    if new_locations_changeset.valid? do
      updated_locations =
        Enum.map(client.locations, &Map.from_struct(&1)) ++
          [Ecto.Changeset.apply_changes(new_locations_changeset)]

      client_changeset =
        client
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_embed(:locations, updated_locations)

      case Repo.update(client_changeset) do
        {:ok, updated_client} -> {:ok, updated_client}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, new_locations_changeset}
    end
  end

  @doc """
    Updates an existing location for client
  """
  def update_location(client, location_item) do
    location_id = location_item["id"] || location_item[:id]

    exisiting_location =
      Enum.find(client.locations, fn location -> location.id == location_id end)

    if exisiting_location do
      update_locations_changeset = Location.changeset(exisiting_location, location_item)

      if update_locations_changeset.valid? do
        updated_location = Ecto.Changeset.apply_changes(update_locations_changeset)

        updated_locations =
          Enum.map(client.locations, fn location ->
            if location.id == exisiting_location.id do
              updated_location
            else
              location
            end
          end)

        updated_locations_map = Enum.map(updated_locations, &Map.from_struct/1)

        client_changeset =
          client
          |> Ecto.Changeset.change(%{locations: updated_locations_map})
          |> Client.locations_changeset(%{locations: updated_locations_map})

        case Repo.update(client_changeset) do
          {:ok, updated_client} -> {:ok, updated_client}
          {:error, changeset} -> {:error, changeset}
        end
      else
        {:error, update_locations_changeset}
      end
    else
      {:error, :location_not_found}
    end
  end
end
