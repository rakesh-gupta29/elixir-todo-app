defmodule Portal.Repo.Migrations.AddClientsTable do
  use Ecto.Migration

  def change do
    # Extension to store case-insensitive data, used for emails
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    # same table is used for auth. so all the value except
    # name, email and password can be null.
    create table(:clients) do
      add :name, :string, null: false
      add :email, :citext, null: false
      add :hashed_password, :string, null: false

      add :confirmed_at, :utc_datetime
      add :description, :string, default: ""
      add :website, :string, default: ""
      add :founded_year, :string, default: ""
      add :is_verified, :boolean, default: false
      add :logo_url, :string, default: ""
      add :tagline, :string, default: ""

      add :manpower_size_id, references(:manpower_ranges, on_delete: :nilify_all)
      add :revenue_range_id, references(:revenue_ranges, on_delete: :nilify_all)
      add :industry_id, references(:industries, on_delete: :nilify_all)

      add :social_profiles, :map, default: %{}
      add :locations, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:clients, [:email])

    # session and authentication tokens for the accounts.
    create table(:clients_tokens) do
      add :user_id, references(:clients, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:clients_tokens, [:user_id])
    create unique_index(:clients_tokens, [:context, :token])
  end
end
