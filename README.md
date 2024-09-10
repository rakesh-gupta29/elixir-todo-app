# Portal

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix

```elixir
defmodule PortalWeb.ClientLive.ProfileLive do
  @moduledoc """
  profile page for clients.
  they can set up their profile along with
  """
  alias Portal.Clients
  import PortalWeb.UI.Button

  use PortalWeb, :live_view_client

  def mount(_params, _session, socket) do
    client = socket.assigns.current_client

    profile_basics_form =
      Clients.update_profile_basics_changeset(client) |> to_form(as: "profile-basics")

    {:ok,
     socket
     |> assign(:trigger_submit, false)
     |> assign(:view_mode, false)
     |> assign(:profile_basics_form, profile_basics_form)}
  end

  def handle_event("toggle_form_mode", _params, socket) do
    mode = socket.assigns.view_mode
    {:noreply, assign(socket, :view_mode, !mode)}
  end

  defp card(assigns) do
    ~H"""
    <article class="grid gap-1">
      <span class="text-base font-normal text-neutral-800"><%= @title %></span>
      <span class="text-lg font-medium text-black">
        <%= if @value == "", do: "-", else: @value %>
      </span>
    </article>
    """
  end

  def handle_event("validate_profile_basics", %{"profile-basics" => params}, socket) do
    client = socket.assigns.current_client

    # Return the updated socket with the updated form and validation action
    {:noreply,
     socket
     |> assign(
       :profile_basics_form,
       client
       |> Clients.update_profile_basics_changeset(params)
       |> to_form(as: "profile-basics")
     )}
  end

  def handle_event("update_profile_basics", %{"profile-basics" => params}, socket) do
    client = socket.assigns.current_client

    case Clients.update_profile_basics(client, params) do
      {:ok, _client} ->
        {:noreply, socket |> put_flash(:info, "profile has been updated")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(socket,
           profile_basics_form: Clients.update_profile_basics_changeset(changeset) |> to_form()
         )}
    end
  end

  def render(assigns) do
    ~H"""
    <div class=" bg-brand/5 pt-20 pb-10">
      <div class="w-container grid grid-cols-3">
        <div class="col-span-1">
          <div class="sticky top-0 grid gap-2 pt-6">
            <span class="text-2xl font-semibold text-brand">Profile details</span>
            <span>Basic details regarding your profile and company</span>
          </div>
        </div>
        <div class="col-span-2 border-1 border-solid bg-white border-brand/10 rounded-xl overflow-hidden">
          <div class="flex  items-center justify-between gap-3 p-4 bg-brand/10">
            <span class="text-xl font-medium text-brand">Basics</span>
            <button
              type="button"
              phx-click="toggle_form_mode"
              class="hover:bg-brand/10 transition-all duration-150 ease-in-out p-1 h-8 w-8 grid place-content-center rounded-full "
            >
              <%= if @view_mode do %>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="size-4"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"
                  />
                </svg>
              <% else %>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="size-4"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                </svg>
              <% end %>
            </button>
          </div>
          <%= if @view_mode do %>
            <div class="p-6  rounded-b-md">
              <div class="grid grid-cols-2 gap-4 pb-4">
                <%= card(%{title: "Company's name", value: @profile_basics_form[:name].value}) %>
                <%= card(%{title: "Founded in", value: @profile_basics_form[:founded_year].value}) %>
                <%= card(%{title: "Tagline", value: @profile_basics_form[:tagline].value}) %>
                <%= card(%{title: "Website", value: @profile_basics_form[:website].value}) %>
              </div>
              <%= card(%{title: "Description", value: @profile_basics_form[:description].value}) %>
            </div>
          <% else %>
            <div class="p-6 rounded-b-md">
              <.simple_form
                novalidate
                for={@profile_basics_form}
                id="profile_basics_form"
                phx-submit="update_profile_basics"
                phx-change="validate_profile_basics"
                phx-trigger-action={false}
              >
                <.input field={@profile_basics_form[:name]} type="text" label="Company name" required />
                <div class="grid gap-6 md:grid-cols-2">
                  <.input
                    field={@profile_basics_form[:website]}
                    type="text"
                    label="Website"
                    required
                    placeholder="https://example.com"
                  />
                  <.input
                    field={@profile_basics_form[:founded_year]}
                    type="number"
                    placeholder="19XX"
                    label="Year founded"
                    required
                  />
                </div>
                <.input
                  field={@profile_basics_form[:tagline]}
                  placeholder="enter company's tagline"
                  type="text"
                  label="Company tagline"
                  required
                />
                <div>
                  <.input
                    rows="7"
                    type="textarea"
                    field={@profile_basics_form[:description]}
                    placeholder="descripe about your company"
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
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end

```
