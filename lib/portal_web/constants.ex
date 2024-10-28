defmodule PortalWeb.Constants do
  @moduledoc """
    defines global consts to be used throughout the application
  """

  # Manpower Ranges:; as defined in the DB.
  # keep this map in sync with the DB table "manpower_ranges"
  def manpower_ranges do
    %{
      "MR001" => "1-10",
      "MR002" => "11-50",
      "MR003" => "51-200",
      "MR004" => "201-500",
      "MR005" => "501-1000",
      "MR006" => "1001-5000",
      "MR007" => "5001-10000",
      "MR008" => "10001+"
    }
  end

  # Revenue Ranges:; as defined in the DB.
  # keep this map in sync with the DB table "revenue_ranges"
  def revenue_ranges do
    %{
      "RR001" => "< $1M",
      "RR002" => "$1M - $10M",
      "RR003" => "$10M - $50M",
      "RR004" => "$50M - $100M",
      "RR005" => "$100M - $500M",
      "RR006" => "$500M - $1B",
      "RR007" => "> $1B"
    }
  end
end
