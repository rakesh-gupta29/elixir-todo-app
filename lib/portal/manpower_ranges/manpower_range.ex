defmodule Portal.ManpowerRanges.ManpowerRange do
  @moduledoc """
    context for manpower ranges
    will be used for showing the size of company as per
    number of employees
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "manpower_ranges" do
    field :name, :string
    field :code, :string
    field :min_value, :integer
    field :max_value, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(manpower_range, attrs) do
    manpower_range
    |> cast(attrs, [:name, :min_value, :max_value, :code])
    |> validate_required([:name, :min_value, :code])
  end
end
