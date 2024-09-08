defmodule Portal.Clients.Client do
  @moduledoc """
    module for clients file
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "clients" do
    field :name, :string
    field :email, :string

    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: false
    field :current_password, :string, virtual: true, redact: true

    field :confirmed_at, :utc_datetime
    field :description, :string
    field :website, :string
    field :founded_year, :string
    field :is_verified, :boolean, default: false
    field :logo_url, :string
    field :tagline, :string
    field :social_profiles, :map, default: %{}
    field :locations, :map, default: %{}

    # Associations
    belongs_to :manpower_size, Portal.ManpowerRanges.ManpowerRange
    belongs_to :revenue_range, Portal.RevenueRanges.RevenueRange
    belongs_to :industry, Portal.Industries.Industry

    timestamps(type: :utc_datetime)
  end

  # changesets
  def registration_changeset(client, attrs, opts \\ []) do
    client
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
    |> validate_name()
    |> validate_email(opts)
    |> validate_password(opts)
  end

  def confirm_client_changeset(client) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(client, confirmed_at: now, is_verified: true)
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 80, message: "should be between 2 and 80 characters")
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must include @ sign and no spaces.")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 2, max: 72)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
    #   message: "at least one digit or punctuation character"
    # )
    |> maybe_hash_password(opts)
  end

  # whether password has to be hashed before inserting into the database.
  # do not use this if using the changeset for liveview form validations
  defp maybe_hash_password(changeset, opts) do
    should_hash? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if should_hash? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  # validates that the email is unique in the database.
  # should be false when using this in the liveview validations
  # always use unsafe_validate in pair with unique as sometimes,
  # the value might be wrong because of data race conditions.
  # I need to read more about this
  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Portal.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  Verifies the password.

  If there is no client or the client doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password_for_user?(%Portal.Clients.Client{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  # if the client struct is not valid, then the first parameter will not be matching.
  def valid_password_for_user?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
    it accepts the changeset for user and field for current password.
    it will then check the password given by user to check against the
    password in the db. else, will apppend an error to the changeset.
  """
  def validate_current_password_for_user(changeset, current_password) do
    changeset = cast(changeset, %{current_password: current_password}, [:current_password])

    if valid_password_for_user?(changeset.data, current_password) do
      changeset
    else
      add_error(changeset, :current_password, "current password is wrong")
    end
  end

  @doc """
    Profile updates for client.
     ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

  """
  def password_changeset(client, attrs, opts \\ []) do
    client
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "passwords do not match")
    |> validate_password(opts)
  end
end
