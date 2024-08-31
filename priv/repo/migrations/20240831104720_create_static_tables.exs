defmodule Portal.Repo.Migrations.CreateAccountsAuthTables do
  use Ecto.Migration

  def change do
    create table(:manpower_ranges) do
      add :name, :string, null: false
      add :code, :string, null: false
      add :min_value, :integer, null: false
      add :max_value, :integer

      timestamps()
    end

    create unique_index(:manpower_ranges, [:code])

    create table(:revenue_ranges) do
      add :name, :string, null: false
      add :code, :string, null: false
      add :min_value, :integer, null: false
      add :max_value, :integer

      timestamps()
    end

    create unique_index(:revenue_ranges, [:code])

    create table(:industries) do
      add :name, :string, null: false
      add :code, :string, null: false
      add :sector, :string

      timestamps()
    end

    create unique_index(:industries, [:code])
    create unique_index(:industries, [:name])
  end
end
