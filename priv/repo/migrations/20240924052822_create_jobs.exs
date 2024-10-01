defmodule Portal.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :overview, :text, null: false
      add :notice_period, :string, null: false
      add :employment_type, :string, null: false
      add :locations, :string, null: false
      add :min_experience, :integer, null: false
      add :max_experience, :integer, null: false
      add :education, :string
      add :currency, :string, default: "INR"
      add :negotiable, :boolean, default: false
      add :is_salary_disclosed, :boolean, default: true
      add :min_salary, :decimal, default: 0
      add :max_salary, :decimal
      add :is_remote, :boolean, default: false
      add :status, :string, default: "open"
      add :skills, :string
      add :application_deadline, :date
      add :number_of_openings, :integer, null: false
      add :benefits, :text
      # Client can not delete his profile until he has any job
      add :client_id, references(:clients, on_delete: :restrict), null: false

      timestamps()
    end
  end
end
