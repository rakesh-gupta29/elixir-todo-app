defmodule PortalWeb.ClientLive.JobsSettingsLive do
  @moduledoc false

  use PortalWeb, :live_view_client

  def mount(_params, _session, socket) do
    {:ok, socket }
  end

  def render(assigns) do
    ~H"""
    <div>
    <div class="w-container-sm blade-top-padding-lg blade-bottom-padding-lg">
      <div class="w-full md:w-11/12 mx-auto">
        <div class="flex justify-center">
          <div class="flex gap-4 shadow-tab_border">
            <a
              href={~p"/app/jobs"}
              class={"text-dark text-opacity-70 px-6 no-underline hover:no-underline focus-visible:no-underline focus:no-underline border-solid border-neutral-700 py-2.5 font-inter hover:text-opacity-100 text-sm tracking-wide transition-colors duration-150 ease-in-out"}
            >
              Home
            </a>
            <a
              href={~p"/app/jobs/settings"}
              class={"text-dark text-opacity-70 px-6  border-b-2 no-underline hover:no-underline focus-visible:no-underline focus:no-underline border-solid border-neutral-700 py-2.5 font-inter hover:text-opacity-100 text-sm tracking-wide transition-colors duration-150 ease-in-out"}
            >
              Settings
            </a>
          </div>
        </div>
        <div>
         <span>check the settings of jobs here</span>
        </div>
      </div>
    </div>
    </div>
    """
  end
end
