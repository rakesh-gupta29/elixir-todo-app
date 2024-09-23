# lib/portal_web/live/client_live/profile_live.ex

defmodule PortalWeb.ClientLive.ProfileLive do
  use PortalWeb, :live_view_client
  alias Portal.Clients
  import PortalWeb.UI.Button

  def mount(_params, _session, socket) do
    client = socket.assigns.current_client

    {:ok,
     socket
     |> assign(:view_mode, false)
     |> assign(:with_modal, false)
     |> assign(:social_profile, nil)
     |> assign(:client, client)
     |> assign(:location, nil)
     |> assign(:social_profile_warning_modal, false)
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

  def apply_action(socket, :add_social_profile, _params) do
    socket
    |> open_modal()
  end

  def apply_action(socket, :add_location, _params) do
    socket
    |> open_modal()
  end

  def apply_action(socket, :edit_location, %{"id" => id}) do
    client = socket.assigns.client

    location =
      Enum.find(client.locations, fn location -> location.id == id end)

    if location do
      socket
      |> assign(:location, location)
      |> open_modal()
    else
      socket
      |> put_flash(:error, "Location not found")
      |> push_patch(to: ~p"/app/profile/locations/add")
    end
  end

  def apply_action(socket, :edit_social_profile, %{"id" => id}) do
    client = socket.assigns.client

    social_profile =
      Enum.find(client.social_profiles, fn profile -> profile.id == id end)

    if social_profile do
      socket
      |> assign(:social_profile, social_profile)
      |> open_modal()
    else
      socket
      |> put_flash(:error, "Social profile not found")
      |> push_patch(to: ~p"/app/profile/socials/add")
    end
  end

  def handle_event("delete_social_profile", %{"id" => id, "name" => name}, socket) do
    {:noreply,
     socket
     |> assign(:social_profile_warning_modal, true)
     |> assign(:social_profile_id, id)
     |> assign(:social_profile_name, name)}
  end

  def handle_event("cancel_profile_delete", _params, socket) do
    {:noreply,
     socket
     |> assign(:social_profile_warning_modal, false)
     |> assign(:social_profile_id, "")
     |> assign(:social_profile_name, "")}
  end

  def handle_event("confirm_profile_delete", %{"id" => id}, socket) do
    case Clients.delete_social_profile(socket.assigns.client, id) do
      {:ok, updated_client} ->
        {
          :noreply,
          socket
          |> assign(:social_profile_warning_modal, false)
          |> assign(:social_profile_id, "")
          |> assign(:client, updated_client)
        }

      {:error, _} ->
        {
          :noreply,
          socket
          |> assign(:social_profile_warning_modal, false)
          |> assign(:social_profile_id, "")
          |> assign(:social_profile_name, "")
        }
    end
  end

  defp open_modal(socket) do
    socket
    |> assign(:with_modal, true)
  end

  def form_component_for_action(:edit_profile_basics), do: PortalWeb.ClientLive.ProfileBasics.Edit

  def form_component_for_action(:add_social_profile),
    do: PortalWeb.ClientLive.ClientSocialProfiles.Add

  def form_component_for_action(:edit_social_profile),
    do: PortalWeb.ClientLive.ClientSocialProfiles.Edit

  def form_component_for_action(:add_location), do: PortalWeb.ClientLive.Locations.Add
  def form_component_for_action(:edit_location), do: PortalWeb.ClientLive.Locations.Edit

  def form_component_for_action(_), do: PortalWeb.ClientLive.ProfileBasics.Edit

  def render(assigns) do
    ~H"""
    <div class="pb-20 bg-brand/5">
      <div class=" pt-20 pb-10">
        <div class="w-container grid grid-cols-3">
          <div class="col-span-1">
            <div class="sticky top-24  pb-10 grid gap-2 pt-6">
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
                id={:edit_profile_basics}
                title={@page_title}
              />
            </div>
          </div>
        </div>
      </div>

      <div class="pt-20 pb-10">
        <div class="w-container grid grid-cols-3">
          <div class="col-span-1">
            <div class="sticky top-24 grid gap-2 pb-10 pt-6">
              <span class="text-2xl font-semibold text-brand">Social Profiles</span>
              <span>Enlist the social profies connected with the account.</span>
            </div>
          </div>
          <div class="col-span-2 border-1 border-solid bg-white border-brand/10 rounded-xl overflow-hidden">
            <div class="flex items-center justify-between gap-3 p-4 bg-brand/10">
              <span class="text-xl font-medium text-brand">Social Profiles</span>
              <a
                href="/app/profile/socials/add"
                class="hover:bg-brand/10 stroke-brand transition-all duration-150 ease-in-out p-1 h-8 w-8 grid place-content-center rounded-full"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="inherit"
                  class="size-6"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                </svg>
              </a>
            </div>
            <div class="p-6 ">
              <.live_component
                module={PortalWeb.ClientLive.SocialProfiles.Show}
                client={@client}
                id={:social_profiles_list}
                title={@page_title}
              />
            </div>
          </div>
        </div>
      </div>

      <div class="pt-20 pb-10">
        <div class="w-container grid grid-cols-3">
          <div class="col-span-1">
            <div class="sticky top-24 grid gap-2 pb-10 pt-6">
              <span class="text-2xl font-semibold text-brand">Locations</span>
              <span>Enlist the office location.</span>
            </div>
          </div>
          <div class="col-span-2 border-1 border-solid bg-white border-brand/10 rounded-xl overflow-hidden">
            <div class="flex items-center justify-between gap-3 p-4 bg-brand/10">
              <span class="text-xl font-medium text-brand">Location</span>
              <a
                href="/app/profile/locations/add"
                class="hover:bg-brand/10 text-gray-900 stroke-brand transition-all duration-150 ease-in-out p-1 h-8 w-8 grid place-content-center rounded-full"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="inherit"
                  class="size-6"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                </svg>
              </a>
            </div>
            <div class="p-6 ">
              <.live_component
                module={PortalWeb.ClientLive.Locations.Show}
                client={@client}
                id={:locations_list}
                title={@page_title}
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <.modal :if={@with_modal} id="client_profile_modal" show on_cancel={JS.patch(~p"/app/profile")}>
      <.live_component
        module={form_component_for_action(@live_action)}
        id={@live_action}
        title={@page_title}
        action={@live_action}
        client={@client}
        social_profile={@social_profile}
        location={@location}
      />
    </.modal>

    <.modal :if={@social_profile_warning_modal} id="social_profile_warning_modal" show>
      <div
        tabindex="-1"
        aria-hidden="true"
        class=" overflow-y-auto overflow-x-hidden  z-50 justify-center items-center w-full md:inset-0 h-[calc(100%-1rem)] max-h-full"
      >
        <div class="relative  w-full max-w-2xl max-h-full">
          <div class="relative bg-white rounded-lg shadow ">
            <div class="p-4 md:p-5 space-y-4">
              <p class="text-2xl  leading-snug font-semibold   text-gray-500 text-neutral-800">
                Delete Profile
              </p>
              <p class="text-base leading-relaxed text-gray-500 text-neutral-600">
                Are you sure you want to delete the social media profile
                <span class="font-semibold text-neutral-800">
                  <%= if @social_profile_name do %>
                    "<%= @social_profile_name %>"
                  <% else %>
                    "Social Media Profile"
                  <% end %>
                </span>
              </p>
            </div>

            <div class="flex items-center justify-end gap-6 pb-1 ">
              <.button
                variant="secondary"
                data-modal-hide="default-modal"
                phx-click="cancel_profile_delete"
                type="button"
              >
                Cancel
              </.button>

              <.button
                variant="destructive"
                phx-click="confirm_profile_delete"
                phx-value-id={@social_profile_id}
                type="button"
              >
                Delete
              </.button>
            </div>
          </div>
        </div>
      </div>
    </.modal>
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

  def handle_info({:social_profiles_updated, updated_client}, socket) do
    {:noreply,
     socket
     |> assign(:client, updated_client)
     |> assign(:with_modal, false)
     |> put_flash(:info, "Social Media profile updated successfully")
     |> push_patch(to: ~p"/app/profile")}
  end

  def handle_info({:add_locations, updated_client}, socket) do
    {:noreply,
     socket
     |> assign(:client, updated_client)
     |> assign(:with_modal, false)
     |> put_flash(:info, "Added location")
     |> push_patch(to: ~p"/app/profile")}
  end

  def handle_info({:locations_updated, updated_client}, socket) do
    {:noreply,
     socket
     |> assign(:client, updated_client)
     |> assign(:with_modal, false)
     |> put_flash(:info, "Updated location")
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
        novalidate
        id="profile_basics_form"
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

# shows the list of social profiles
defmodule PortalWeb.ClientLive.SocialProfiles.Show do
  @moduledoc """
  Handles the rendering of existing social media profiles.
  """

  use PortalWeb, :live_component

  import PortalWeb.UI.Button

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :flash_message, "check this ")}
  end

  def render(assigns) do
    ~H"""
    <div class="divide-y-[1px] divide-solid divide-brand/10">
      <%= if Enum.empty?(@client.social_profiles) do %>
        <div class="py-4 text-center text-gray-500">
          <p>No social profiles added.</p>
        </div>
      <% else %>
        <%= for profile <- @client.social_profiles do %>
          <div class="flex items-center space-x-4 py-4">
            <div class="flex-1">
              <h4 class="text-lg font-semibold"><%= profile.name %></h4>
              <a href={normalize_url(profile.url)} target="_blank" class="text-sm text-gray-500">
                <%= profile.url %>
              </a>
            </div>
            <div class="flex items-center gap-3">
              <a
                href={"/app/profile/socials/#{profile.id}/edit"}
                class="min-h-[32px] max-h-[32px] stroke-neutral-700 min-w-[32px] max-w-[32px] p-2 grid place-content-center place-items-center rounded-full hover:bg-neutral-100 transition-all duration-150 ease-in-out "
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
              <button
                type="button"
                class="min-h-[32px] max-h-[32px] stroke-red-500 min-w-[32px] max-w-[32px] p-2 grid place-content-center place-items-center rounded-full hover:bg-neutral-100 transition-all duration-150 ease-in-out "
                phx-click="delete_social_profile"
                phx-value-id={profile.id}
                phx-value-name={profile.name}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  height="24"
                  width="24"
                  viewBox="0 0 24 24"
                  strokeWidth={1.5}
                  stroke="inherit"
                  className="h-[20px] w-[20px]"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"
                  />
                </svg>
              </button>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  # Updated handle_event to correctly capture the "id" from the button click event
  def handle_event("delete_social_profile", %{"id" => profile_id}, socket) do
    # You can add logic here for deleting the profile
    # For now, we'll just show a flash message
    flash_message = "Profile with ID #{profile_id} deleted"

    # Update the socket with the flash message
    {:noreply, assign(socket, :flash_message, flash_message)}
  end

  defp normalize_url(url) do
    if String.starts_with?(url, ["http://", "https://"]) do
      url
    else
      "https://" <> url
    end
  end
end

# adds a social media profile to the list
defmodule PortalWeb.ClientLive.ClientSocialProfiles.Add do
  @moduledoc """
    add one profile to the list of social profile
  """
  use PortalWeb, :live_component
  import PortalWeb.UI.Button
  alias Portal.Clients

  alias Portal.Client.SocialProfile

  def update(%{client: _client, action: action} = assigns, socket) do
    changeset = SocialProfile.changeset(%SocialProfile{}, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:action, action)
     |> assign(:form, to_form(changeset, as: "social_profile_item"))}
  end

  def handle_event("validate", %{"social_profile_item" => profile_params}, socket) do
    changeset =
      Map.put(SocialProfile.changeset(%SocialProfile{}, profile_params), :action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset, as: "social_profile_item"))}
  end

  def handle_event("save", %{"social_profile_item" => social_profile}, socket) do
    changeset = SocialProfile.changeset(%SocialProfile{}, social_profile)

    if changeset.valid? do
      save_social_item(socket, socket.assigns.action, social_profile)
    else
      {:ok,
       socket
       |> assign(:form, to_form(Map.put(changeset, :action, :insert), as: "social_profile_item"))}
    end
  end

  def save_social_item(socket, :add_social_profile, profile_item) do
    case Clients.add_client_social_profile(socket.assigns.client, profile_item) do
      {:ok, updated_client} ->
        send(self(), {:social_profiles_updated, updated_client})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "Failed to save social profile.")}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        novalidate
        id="social_profile_item"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Company name" required />
        <.input field={@form[:url]} type="text" label="Company name" required />
        <:actions>
          <div class="w-full grid place-content-end">
            <.button phx-disable-with="Updating...">Add handle</.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end

defmodule PortalWeb.ClientLive.Locations.Show do
  @moduledoc false

  use PortalWeb, :live_component

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="divide-y-[1px] divide-solid divide-brand/10">
      <%= if Enum.empty?(@client.locations) do %>
        <div class="py-4 text-center text-gray-500">
          <p>No locations added yet.</p>
        </div>
      <% else %>
        <%= for location <- @client.locations do %>
          <div class="flex items-center space-x-4 py-4">
            <div class="flex-1">
              <h4 class="text-lg font-semibold"><%= location.name %></h4>
              <h4 class="text-lg font-normal text-neutral-600"><%= location.address %></h4>
            </div>
            <div class="flex items-center gap-3">
              <a
                href={"/app/profile/locations/#{location.id}/edit"}
                class="min-h-[32px] max-h-[32px] stroke-neutral-700 min-w-[32px] max-w-[32px] p-2 grid place-content-center place-items-center rounded-full hover:bg-neutral-100 transition-all duration-150 ease-in-out "
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
              <button
                type="button"
                class="min-h-[32px] max-h-[32px] stroke-red-500 min-w-[32px] max-w-[32px] p-2 grid place-content-center place-items-center rounded-full hover:bg-neutral-100 transition-all duration-150 ease-in-out "
                phx-click="delete_social_profile"
                phx-value-id={location.id}
                phx-value-name={location.name}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  height="24"
                  width="24"
                  viewBox="0 0 24 24"
                  strokeWidth={1.5}
                  stroke="inherit"
                  className="h-[20px] w-[20px]"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"
                  />
                </svg>
              </button>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end
end

defmodule PortalWeb.ClientLive.Locations.Add do
  @moduledoc false

  use PortalWeb, :live_component

  alias Portal.Clients
  import PortalWeb.UI.Button

  alias Portal.Client.Location

  def update(%{client: _client, action: action} = assigns, socket) do
    changeset = Location.changeset(%Location{}, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:action, action)
     |> assign(:form, to_form(changeset, as: "add_locations_form"))}
  end

  def handle_event("validate", %{"add_locations_form" => params}, socket) do
    changeset =
      Map.put(Location.changeset(%Location{}, params), :action, :validate)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, as: "add_locations_form"))}
  end

  def handle_event("save", %{"add_locations_form" => params}, socket) do
    changeset = Location.changeset(%Location{}, params)

    if changeset.valid? do
      save_location(socket, params)
    else
      {:noreply,
       socket
       |> assign(form: to_form(Map.put(changeset, :action, :insert), as: "add_locations_form"))}
    end
  end

  def save_location(socket, item) do
    case Clients.add_location(socket.assigns.client, item) do
      {:ok, updated_client} ->
        send(self(), {:add_locations, updated_client})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "failed to add the location")}

      {:error, :not_found} ->
        {:noreply, socket |> put_flash(:info, "failed to load the location")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="pt-4">
      <.simple_form
        for={@form}
        novalidate
        id="add_locations_form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Company name" required />
        <.input field={@form[:city]} type="text" label="City" required />
        <.input field={@form[:address]} type="text" label="Address" required />
        <.input field={@form[:map_url]} type="url" label="Map URL(optional)" />

        <:actions>
          <div class="w-full grid place-content-end">
            <.button phx-disable-with="Updating...">Add handle</.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end

# edits a social media profile to the list
defmodule PortalWeb.ClientLive.ClientSocialProfiles.Edit do
  @moduledoc """
    renders a form for handling the edit of social profiles
  """
  use PortalWeb, :live_component
  import PortalWeb.UI.Button
  alias Portal.Clients

  alias Portal.Client.SocialProfile

  def update(%{action: action, social_profile: profile_item} = assigns, socket) do
    changeset = SocialProfile.changeset(profile_item, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:action, action)
     |> assign(:form, to_form(changeset, as: "social_profile_item"))}
  end

  def handle_event("validate", %{"social_profile_item" => profile_params}, socket) do
    changeset =
      Map.put(SocialProfile.changeset(%SocialProfile{}, profile_params), :action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset, as: "social_profile_item"))}
  end

  def handle_event("save", %{"social_profile_item" => social_profile}, socket) do
    changeset = SocialProfile.changeset(%SocialProfile{}, social_profile)

    if changeset.valid? do
      save_social_item(socket, social_profile)
    else
      {:noreply,
       socket
       |> assign(:form, to_form(Map.put(changeset, :action, :insert), as: "social_profile_item"))}
    end
  end

  def save_social_item(socket, profile_item) do
    case Clients.update_client_social_profile(socket.assigns.client, profile_item) do
      {:ok, updated_client} ->
        send(self(), {:social_profiles_updated, updated_client})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "Failed to edit social profile.")}

      {:error, :social_profile_not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "item not found")}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        novalidate
        id="social_profile_item"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="hidden" label="name of project" required />
        <.input field={@form[:name]} type="text" label="name of project" required />
        <.input field={@form[:url]} type="text" label="url for project" required />
        <:actions>
          self
          <div class="w-full grid place-content-end">
            <.button phx-disable-with="Updating...">Add handle</.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end

defmodule PortalWeb.ClientLive.Locations.Edit do
  @moduledoc false

  use PortalWeb, :live_component

  import PortalWeb.UI.Button
  alias Portal.Client.Location
  alias Portal.Clients

  def update(%{action: action, location: profile_item} = assigns, socket) do
    changeset = Location.changeset(profile_item, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:action, action)
     |> assign(:form, to_form(changeset, as: "edit_locations_item"))}
  end

  def handle_event("validate", %{"edit_locations_item" => location_params}, socket) do
    changeset = Map.put(Location.changeset(%Location{}, location_params), :action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset, as: "edit_locations_item"))}
  end

  def handle_event("save", %{"edit_locations_item" => location_item}, socket) do
    changeset = Location.changeset(%Location{}, location_item)

    if changeset.valid? do
      save_location_item(socket, location_item)
    else
      {:noreply,
       socket
       |> assign(:form, to_form: Map.put(changeset, :action, :insert)), as: "edit_locations_item"}
    end
  end

  def save_location_item(socket, item) do
    case Clients.update_location(socket.assigns.client, item) do
      {:ok, updated_client} ->
        IO.inspect("done")
        send(self(), {:locations_updated, updated_client})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "failed to update the location")}

      {:error, :location_not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, "location is not found")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="pt-4">
      <.simple_form
        for={@form}
        novalidate
        id="edit_locations_item"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:id]} type="hidden" label="name of project" required />
        <.input field={@form[:name]} type="text" label="Company name" required />
        <.input field={@form[:city]} type="text" label="City" required />
        <.input field={@form[:address]} type="text" label="Address" required />
        <.input field={@form[:map_url]} type="url" label="Map URL(optional)" />

        <:actions>
          <div class="w-full grid place-content-end">
            <.button phx-disable-with="Updating...">Edit location</.button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
