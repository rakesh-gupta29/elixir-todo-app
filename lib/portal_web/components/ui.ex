defmodule PortalWeb.UI do
  @moduledoc false

  def component do
    quote do
      use Phoenix.Component
      import PortalWeb.UI.Helpers
      import Tails, only: [classes: 1]
      alias Phoenix.LiveView.JS
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  defmacro __using__(_) do
    quote do
      import PortalWeb.UI.Anchor
      import PortalWeb.UI.Button
    end
  end
end
