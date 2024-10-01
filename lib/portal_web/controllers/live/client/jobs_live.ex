defmodule PortalWeb.ClientLive.JobsLive do
  @moduledoc """
  Page for the list of current jobs.
  """
  use PortalWeb, :live_view_client

  def mount(_params, _session, socket) do
    client_id = socket.assigns.current_client.id

    {:ok,
     socket
     |> assign_async(:jobs, fn -> fetch_things(client_id) end)
     |> assign(:current_path, "")
     |> assign(:page_title, "List of jobs for client")}
  end

  defp fetch_things(client_id) do
    jobs = Portal.Jobs.get_all_jobs(client_id)

    if jobs do
      {:ok, %{jobs: jobs}}
    else
      {:error, "failed to fetch the list"}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={PortalWeb.JobsLive.JobCard}
        jobs={@jobs}
        id={:list_of_jobs}
        title={@page_title}
        current_path={@current_path}
      />
    </div>
    """
  end
end

defmodule PortalWeb.JobsLive.JobCard do
  @moduledoc false

  use PortalWeb, :live_component

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="w-container-sm blade-top-padding-lg blade-bottom-padding-lg">
      <div class="w-full md:w-11/12 mx-auto">
        <div class="flex justify-center">
          <div class="flex gap-4 shadow-tab_border">
            <a
              href={~p"/app/jobs"}
              class="text-dark text-opacity-70 px-6 border-b-2 no-underline hover:no-underline focus-visible:no-underline focus:no-underline border-solid border-neutral-700 py-2.5 font-inter hover:text-opacity-100 text-sm tracking-wide transition-colors duration-150 ease-in-out"
            >
              Home
            </a>

            <a
              href={~p"/app/jobs/settings"}
              class="text-dark text-opacity-70 px-6  no-underline hover:no-underline focus-visible:no-underline focus:no-underline border-solid border-neutral-700 py-2.5 font-inter hover:text-opacity-100 text-sm tracking-wide transition-colors duration-150 ease-in-out"
            >
              Settings
            </a>
          </div>
        </div>
        <div>
          <.async_result :let={jobs} assign={@jobs}>
            <:loading>Loading organization...</:loading>
            <:failed :let={_failure}>there was an error loading the organization</:failed>
            <%= if jobs  do %>
              <%= if Enum.empty?(jobs ) do %>
                <span>No jobs found for the user</span>
              <% else %>
                <div class="max-w-7xl mx-auto px-3 md:w-11/12 grid grid-cols-3  gap-6 blade-top-padding-sm">
                  <%= for job <- jobs do %>
                    <a
                      href={~p"/jobs/#{job.id}"}
                      class="no-underline hover:no-underline focus-visible:no-underline "
                    >
                      <article class="p-4 rounded-lg hover:bg-neutral-100 hover:ring-1 ring-neutral-300 ring-offset-1 transition-colors duration-150 ease-in-out cursor-pointer border-[1px] border-solid border-neutral-300 bg-neutral-50 grid gap-1">
                        <span class="text-xl font-semibold text-neutral-900
             ">
                          <%= job.title %>
                        </span>
                        <span class="text-neutral-700 "><%= job.overview %></span>
                      </article>
                    </a>
                  <% end %>
                </div>
              <% end %>
            <% else %>
              <span>Failed to load the jobs</span>
            <% end %>
          </.async_result>
        </div>
      </div>
    </div>
    """
  end
end
