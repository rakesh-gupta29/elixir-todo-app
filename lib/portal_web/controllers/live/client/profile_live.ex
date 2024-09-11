# lib/portal_web/live/client_live/profile_live.ex

defmodule PortalWeb.ClientLive.ProfileLive do
  use PortalWeb, :live_view_client
  alias Portal.Clients
  alias Portal.Clients.Client

  def mount(_params, _session, socket) do
    client = socket.assigns.current_client

    {:ok,
     socket
     |> assign(:view_mode, false)
     |> assign(:with_modal, false)
     |> assign(:client, client)
     |> assign(:page_title, "")}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :new, _params) do
    socket
  end

  def apply_action(socket, :edit_profile_basics, _params) do
    socket
    |> open_modal()
  end

  defp open_modal(socket) do
    socket
    |> assign(:with_modal, true)
  end

  def form_component_for_action(:edit_profile_basics), do: PortalWeb.ClientLive.ProfileBasics.Edit
  def form_component_for_action(_), do: PortalWeb.ClientLive.ProfileBasics.Edit

  def render(assigns) do
    ~H"""
    <div class="bg-brand/5 pt-20 pb-10">
      <div class="w-container grid grid-cols-3">
        <div class="col-span-1">
          <div class="sticky top-0 grid gap-2 pt-6">
            <span class="text-2xl font-semibold text-brand">Profile details</span>
            <span>Basic details regarding your profile and company</span>
          </div>
        </div>
        <div class="col-span-2 border-1 border-solid bg-white border-brand/10 rounded-xl overflow-hidden">
          <div class="flex items-center justify-between gap-3 p-4 bg-brand/10">
            <span class="text-xl font-medium text-brand">Basics</span>
            <a
              href="/app/profile/basics/edit"
              class="hover:bg-brand/10 stroke-brand transition-all duration-150 ease-in-out p-1 h-8 w-8 grid place-content-center rounded-full"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="inherit"
                class="size-4"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"
                />
              </svg>
            </a>
          </div>
          <div class="p-6 ">
            <.live_component
              module={PortalWeb.ClientLive.ProfileBasics.Show}
              client={@client}
              id={@client.id || :new}
              title={@page_title}
            />
          </div>
        </div>
      </div>

      <.modal :if={@with_modal} id="client_profile_modal" show on_cancel={JS.patch(~p"/app/profile")}>
        <.live_component
          module={form_component_for_action(@live_action)}
          id={@client.id || :new}
          title={@page_title}
          action={@live_action}
          client={@client}
        />
      </.modal>
    </div>
    """
  end

  def handle_info({:profile_updated, updated_client}, socket) do
    {:noreply,
     socket
     |> assign(:client, updated_client)
     |> assign(:with_modal, false)
     |> put_flash(:info, "Profile updated successfully")
     |> push_patch(to: ~p"/app/profile")}
  end
end

defmodule PortalWeb.ClientLive.ProfileBasics.Show do
  use PortalWeb, :live_component

  defp tile(assigns) do
    ~H"""
    <article class="grid gap-1 grid-cols-4 py-6">
      <span class="text-base font-medium text-neutral-800 col-span-1"><%= @title %></span>
      <span class="text-base font-normal text-black col-span-3">
        <%= if @value == "", do: "-", else: @value %>
      </span>
    </article>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="divide-y-[1px] divide divide-solid divide-brand/10">
      <%= tile(%{title: "Name", value: @client.name}) %>
      <%= tile(%{title: "Email", value: @client.email}) %>
      <%= tile(%{title: "Year of foundation", value: @client.founded_year}) %>
      <%= tile(%{title: "Tagline", value: @client.tagline}) %>
      <%= tile(%{title: "Description", value: @client.description}) %>
    </div>
    """
  end
end

defmodule PortalWeb.ClientLive.ProfileBasics.Edit do
  use PortalWeb, :live_component
  alias Portal.Clients
  import PortalWeb.UI.Button

  def update(%{client: client, action: action} = assigns, socket) do
    changeset = Clients.update_profile_basics_changeset(client)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:action, action)
     |> assign(:form, to_form(changeset, as: "profile_form"))}
  end

  def handle_event("validate", %{"profile_form" => profile_params}, socket) do
    changeset =
      socket.assigns.client
      |> Clients.update_profile_basics_changeset(profile_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: "profile_form"))}
  end

  def handle_event("save", %{"profile_form" => profile_params}, socket) do
    save_profile(socket, socket.assigns.action, profile_params)
  end

  defp save_profile(socket, :edit_profile_basics, profile_params) do
    case Clients.update_profile_basics(socket.assigns.client, profile_params) do
      {:ok, client} ->
        send(self(), {:profile_updated, client})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: "profile_form"))}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="profile_form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Company name" required />
        <div class="grid gap-6 md:grid-cols-2">
          <.input
            field={@form[:website]}
            type="text"
            label="Website"
            required
            placeholder="https://example.com"
          />
          <.input
            field={@form[:founded_year]}
            type="number"
            placeholder="19XX"
            label="Year founded"
            required
          />
        </div>
        <.input
          field={@form[:tagline]}
          placeholder="enter company's tagline"
          type="text"
          label="Company tagline"
          required
        />
        <div>
          <.input
            rows="7"
            type="textarea"
            field={@form[:description]}
            placeholder="describe about your company"
            label="Description"
          />
        </div>

        <:actions>
          <div class="w-full grid place-content-end">
            <.button phx-disable-with="Updating...">Update profile</.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
