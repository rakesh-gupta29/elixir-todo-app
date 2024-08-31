defmodule Portal.Industries.Industry do
  @moduledoc """
  static dataset for industries.
  for visual and autocomplete purpose
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "industries" do
    field :name, :string
    field :code, :string
    field :sector, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(industry, attrs) do
    industry
    |> cast(attrs, [:name, :code, :sector])
    |> validate_required([:name, :code])
  end
end
