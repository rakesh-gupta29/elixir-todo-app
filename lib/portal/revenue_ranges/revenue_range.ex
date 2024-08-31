defmodule Portal.RevenueRanges.RevenueRange do
  @moduledoc """
  Context for revenue ranges.
  used for showing the size of company as per revenue
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "revenue_ranges" do
    field :name, :string
    field :code, :string
    field :min_value, :integer
    field :max_value, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(revenue_range, attrs) do
    revenue_range
    |> cast(attrs, [:name, :code, :min_value, :max_value])
    |> validate_required([:name, :code, :min_value])
  end
end
