defmodule PortalWeb.UI.Anchor do
  @moduledoc false
  use PortalWeb.UI, :component

  @doc """
  Renders a anchor.

  ## Examples

      <.anchor>Send!</.anchor>
      <.anchor phx-click="go" class="ml-2">Send!</.anchor>
  """
  attr(:class, :string, default: nil)
  attr(:href, :string, default: "#")

  attr(:variant, :string,
    values: ~w(primary secondary destructive outline ghost link),
    default: "primary",
    doc: "the anchor styles"
  )

  attr(:size, :string, values: ~w(default sm lg icon), default: "default")
  attr(:icon, :string, default: nil)
  attr(:icon_right, :string, default: nil)
  attr(:rest, :global, include: ~w(name))

  slot(:inner_block, required: true)

  def(anchor(assigns)) do
    assigns = assign(assigns, :variant_class, anchor_variant(assigns.variant, assigns.size))

    ~H"""
    <a
      href={@href}
      class={
        classes([
          "inline-flex  underline-none text-inherit hover:no-underline  items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
          @variant_class,
          "gap-1",
          "phx-submit-loading:opacity-75 btn",
          @class
        ])
      }
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  @anchor_variants %{
    "primary" => "bg-brand text-white hover:bg-brand/90",
    "secondary" =>
      "bg-secondary text-secondary-foreground border-brand border-[1px] border-solid hover:bg-brand/10",
    "destructive" => "bg-destructive text-destructive-foreground hover:bg-destructive/90",
    "outline" =>
      "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground",
    "ghost" => "hover:bg-accent hover:text-accent-foreground",
    "link" => "text-primary underline-offset-4 hover:underline"
  }

  @anchor_sizes %{
    "default" => "h-10 px-4 py-2",
    "sm" => "h-8 rounded-md px-3 text-sm",
    "lg" => "h-11 rounded-md px-8",
    "icon" => "h-10 w-10"
  }
  def anchor_variant(variant \\ "primary", size \\ "default") do
    Enum.join([@anchor_variants[variant], @anchor_sizes[size]], " ")
  end
end
