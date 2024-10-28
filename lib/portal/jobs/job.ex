defmodule Portal.Jobs.Job do
  @moduledoc """
  Jobs module
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :title, :string
    field :description, :string
    field :overview, :string
    field :notice_period, :string
    field :employment_type, :string
    field :locations, :string
    field :min_experience, :integer
    field :max_experience, :integer
    field :education, :string
    field :currency, :string, default: "INR"
    field :negotiable, :boolean, default: false
    field :is_salary_disclosed, :boolean, default: true
    field :min_salary, :decimal, default: 0
    field :max_salary, :decimal
    field :is_remote, :boolean, default: false
    field :status, :string, default: "open"
    field :skills, :string
    field :application_deadline, :date
    field :number_of_openings, :integer
    # Updated to :text for consistency with migration
    field :benefits, :string

    belongs_to :client, Portal.Clients.Client, foreign_key: :client_id

    timestamps(type: :utc_datetime)
  end

  # need company name here too
  # need the notice period negotiable thing too like is the notice period negotiable or not
  # locations for the id, need to be an array of the locations

  @employment_types ["full time", "remote", "contract", "part time", "freelance", "others"]
  @currencies ["INR", "USD"]
  @statuses ["open", "closed", "paused"]

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [
      :title,
      :description,
      :overview,
      :notice_period,
      :employment_type,
      :locations,
      :min_experience,
      :max_experience,
      :education,
      :currency,
      :negotiable,
      :is_salary_disclosed,
      :min_salary,
      :max_salary,
      :is_remote,
      :status,
      :skills,
      :application_deadline,
      :number_of_openings,
      :benefits,
      :client_id
    ])
    |> validate_required([
      :title,
      :description,
      :employment_type,
      :locations,
      :min_experience,
      :max_experience,
      :client_id,
      :overview,
      :notice_period,
      :number_of_openings
    ])
    |> validate_length(:title, max: 255)
    |> validate_length(:employment_type, max: 50)
    |> validate_length(:education, max: 100)
    |> validate_length(:currency, is: 3)
    |> validate_length(:status, max: 20)
    |> validate_length(:notice_period, max: 50)
    |> validate_number(:min_experience, greater_than_or_equal_to: 0, less_than_or_equal_to: 50)
    |> validate_number(:max_experience,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 50,
      message: "must be greater than min experience"
    )
    |> validate_number(:number_of_openings, greater_than: 0, less_than_or_equal_to: 1000)
    |> validate_number(:min_salary,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 10_000_000
    )
    |> validate_number(:max_salary,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 10_000_000
    )
    |> validate_inclusion(:currency, @currencies)
    |> validate_inclusion(:employment_type, @employment_types)
    |> validate_inclusion(:status, @statuses)
    |> validate_salary_range()
    |> validate_experience_range()
    |> validate_future_date(:application_deadline)
    |> foreign_key_constraint(:client_id)
  end

  defp validate_salary_range(changeset) do
    min_salary = get_field(changeset, :min_salary)
    max_salary = get_field(changeset, :max_salary)

    if min_salary && max_salary && Decimal.compare(max_salary, min_salary) == :lt do
      add_error(changeset, :max_salary, "must be greater than or equal to min_salary")
    else
      changeset
    end
  end

  defp validate_experience_range(changeset) do
    min_exp = get_field(changeset, :min_experience)
    max_exp = get_field(changeset, :max_experience)

    if min_exp && max_exp && max_exp < min_exp do
      add_error(changeset, :max_experience, "must be greater than or equal to min_experience")
    else
      changeset
    end
  end

  defp validate_future_date(changeset, field) do
    date = get_field(changeset, field)

    if date && Date.compare(date, Date.utc_today()) == :lt do
      add_error(changeset, field, "must be in the future")
    else
      changeset
    end
  end
end
