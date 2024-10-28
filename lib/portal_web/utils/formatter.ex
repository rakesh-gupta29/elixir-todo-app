defmodule PortalWeb.Utils.Formatter do
  @moduledoc """
    contains a series of utils for the formatting the inputs. generally used for views.
  """

  alias PortalWeb.Constants

  @doc """
    Gets the manpower range for the given code. geenrally used for formatting to be shown in the views
  """
  def get_manpower_range(code) when is_binary(code) do
    Constants.manpower_ranges()
    |> Map.get(code, "N/A")
  end

  @doc """
  Gets the revenue range for the given code. geenrally used for formatting to be shown in the views
  """

  def get_revenue_range(code) when is_binary(code) do
    Constants.revenue_ranges()
    |> Map.get(code, "N/A")
  end
end
