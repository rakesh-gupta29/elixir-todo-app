defmodule PortalWeb.UI.Button do
  @moduledoc false
  use PortalWeb.UI, :component

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)

  attr(:variant, :string,
    values: ~w(primary secondary destructive outline ghost link),
    default: "primary",
    doc: "the button variant style"
  )

  attr(:size, :string, values: ~w(default sm lg icon), default: "default")
  attr(:icon, :string, default: nil)
  attr(:icon_right, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def(button(assigns)) do
    assigns = assign(assigns, :variant_class, button_variant(assigns.variant, assigns.size))

    ~H"""
    <button
      type={@type}
      class={
        classes([
          "inline-flex items-center justify-center rounded-full text-sm font-medium  transition-colors focus-visible:outline-none ring-offset-1 focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
          @variant_class,
          "gap-1",
          "phx-submit-loading:opacity-75 btn",
          @class
        ])
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @button_variants %{
    "primary" => "bg-brand text-white hover:bg-brand/90",
    "secondary" =>
      "bg-secondary text-secondary-foreground border-brand border-[1px] border-solid hover:bg-brand/10",
    "destructive" =>
      "bg-red-700 text-white hover:bg-opacity-90 border-none focus-visible:ring-red-500  outline-none ring-none ",
    "outline" =>
      "border border-input bg-none shadow-sm hover:bg-accent hover:text-accent-foreground",
    "ghost" => "hover:bg-accent hover:text-accent-foreground",
    "link" => "text-primary underline-offset-4 hover:underline"
  }

  @button_sizes %{
    "default" => "h-10 px-4 py-2",
    "sm" => "h-8 rounded-full px-3 text-sm",
    "lg" => "h-11 rounded-full px-8",
    "icon" => "h-10 w-10"
  }
  def button_variant(variant \\ "primary", size \\ "default") do
    Enum.join([@button_variants[variant], @button_sizes[size]], " ")
  end
end
