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
    field :hashed_password, :string, redact: true
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
    |> validate_length(:password, min: 12, max: 72)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
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
end
