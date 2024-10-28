defmodule PortalWeb.JobsLive.JobDetails do
  @moduledoc """
    view the details of the page
  """
  use PortalWeb, :live_view

  import PortalWeb.UI.Button

  alias Portal.Jobs

  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:withLayout, false)
     |> assign_async([:job], fn -> fetch_job_details(id) end)}
  end

  defp fetch_job_details(id) do
    case Integer.parse(id) do
      {id, ""} ->
        case Jobs.job_with_id(id) do
          nil ->
            {:error, "job is not found. but id is valid"}

          job ->
            IO.inspect(job)
            {:ok, %{job: job, withLayout: true}}
        end

      _ ->
        {:error, "invalid id param"}
    end
  end

  def format_experience(min, max) do
    cond do
      min == 0 and max == 0 ->
        "Fresher"

      min == 0 and max > 0 ->
        "Up to #{max} #{if max == 1, do: "year", else: "years"}"

      min > 0 and max == 0 ->
        "#{min} #{if min == 1, do: "year", else: "years"} or more"

      min == max ->
        "#{min} #{if min == 1, do: "year", else: "years"}"

      true ->
        "#{min} - #{max} #{if max == 1, do: "year", else: "years"}"
    end
  end

  def relative_time(%DateTime{} = datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 ->
        "just now"

      diff < 3600 ->
        minutes = div(diff, 60)
        "#{minutes} minutes ago"

      diff < 86400 ->
        hours = div(diff, 3600)
        "#{hours} hours ago"

      true ->
        days = div(diff, 86400)
        "#{days} days ago"
    end
  end

  def format_salary(min, max, currency) do
    currency_symbol =
      case currency do
        "INR" -> "₹"
        "USD" -> "$"
        _ -> ""
      end

    cond do
      min == 0 and max == 0 ->
        "N/A"

      min > 0 and max == 0 ->
        "Starts from #{currency_symbol}#{format_amount(min)}"

      min == 0 and max > 0 ->
        "Up to #{currency_symbol}#{format_amount(max)}"

      min == max ->
        "#{currency_symbol}#{format_amount(min)}"

      true ->
        "#{currency_symbol}#{format_amount(min)} - #{format_amount(max)}"
    end
  end

  defp format_amount(amount) when is_float(amount) or is_integer(amount) do
    amount
    |> :erlang.float_to_binary(decimals: 0, compact: true)
    |> String.replace(~r/(\d)(?=(\d{3})+(?!\d))/, "\\1,")
  end

  def render(assigns) do
    ~H"""
    <section class="bg-light-gray">
      <.async_result :let={job} assign={@job}>
        <:loading>
          <div class="h-full grid place-content-center blade-bottom-padding-lg place-items-center  min-h-screen ">
            <.loader />
          </div>
        </:loading>
        <:failed>
          <span>failed to load the results </span>
        </:failed>

        <section class="bg-light-gray min-h-screen">
          <div class="max-w-screen-xl mx-auto  gap-6 blade-top-padding-sm grid grid-cols-7 blade-bottom-padding">
            <div class=" border-[1px] border-solid col-span-5 border-[#EBEBEB]">
              <div class="px-6 pt-10 pb-8">
                <h1 class="text-3xl font-semibold pb-3 text-[#171717]">
                  <%= job.title %>
                </h1>
                <span class="text-[#666666]">Temporary company name</span>

                <div class="flex items-center gap-8 pt-8">
                  <div class="flex items-center gap-2">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="#666666"
                      class="size-5"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M20.25 14.15v4.25c0 1.094-.787 2.036-1.872 2.18-2.087.277-4.216.42-6.378.42s-4.291-.143-6.378-.42c-1.085-.144-1.872-1.086-1.872-2.18v-4.25m16.5 0a2.18 2.18 0 0 0 .75-1.661V8.706c0-1.081-.768-2.015-1.837-2.175a48.114 48.114 0 0 0-3.413-.387m4.5 8.006c-.194.165-.42.295-.673.38A23.978 23.978 0 0 1 12 15.75c-2.648 0-5.195-.429-7.577-1.22a2.016 2.016 0 0 1-.673-.38m0 0A2.18 2.18 0 0 1 3 12.489V8.706c0-1.081.768-2.015 1.837-2.175a48.111 48.111 0 0 1 3.413-.387m7.5 0V5.25A2.25 2.25 0 0 0 13.5 3h-3a2.25 2.25 0 0 0-2.25 2.25v.894m7.5 0a48.667 48.667 0 0 0-7.5 0M12 12.75h.008v.008H12v-.008Z"
                      />
                    </svg>
                    <span class="text-[#666666] text-base">
                      <%= format_experience(job.min_experience, job.max_experience) %>
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <%= if job.currency == "USD" do %>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="#666666"
                        class="size-5"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M12 6v12m-3-2.818.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
                        />
                      </svg>
                    <% else %>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="#666666"
                        class="size-5"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M15 8.25H9m6 3H9m3 6-3-3h1.5a3 3 0 1 0 0-6M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
                        />
                      </svg>
                    <% end %>

                    <span class="text-[#666666] text-base">
                      <%= if job.is_salary_disclosed == true,
                        do: "Not disclosed",
                        else: format_salary(job.min_salary, job.max_salary, job.currency) %>
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="#666666"
                      class="size-5"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
                      />
                    </svg>

                    <span class="text-[#666666] text-base">
                      <%= job.notice_period %>
                      <%= if job.negotiable == true,
                        do: "(Negotiable)",
                        else: "" %>
                    </span>
                  </div>
                </div>
                <div class="pt-4 flex items-center gap-8">
                  <div class="flex items-center gap-2">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="#666666"
                      class="size-5"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M2.25 21h19.5m-18-18v18m10.5-18v18m6-13.5V21M6.75 6.75h.75m-.75 3h.75m-.75 3h.75m3-6h.75m-.75 3h.75m-.75 3h.75M6.75 21v-3.375c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21M3 3h12m-.75 4.5H21m-3.75 3.75h.008v.008h-.008v-.008Zm0 3h.008v.008h-.008v-.008Zm0 3h.008v.008h-.008v-.008Z"
                      />
                    </svg>
                    <span class="text-[#666666] text-base">
                      <%= if job.is_remote == true, do: "Remote", else: job.locations %>
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="#666666"
                      class="size-5"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z"
                      />
                    </svg>

                    <span class="text-[#666666] text-base"><%= job.employment_type %></span>
                  </div>
                </div>
              </div>
              <div class="border-t-[1px] gap-6 border-solid border-[#EBEBEB] flex items-center justify-between px-6 pb-6 pt-6">
                <div class="flex items-center gap-6">
                  <div class="flex gap-2 items-center">
                    <span class="text-sm text-[#7D7D7D]">Posted:</span>
                    <span class="text-sm text-[#666] font-medium">
                      <%= relative_time(job.inserted_at) %>
                    </span>
                  </div>
                  <div class="flex gap-2 items-center">
                    <span class="text-sm text-[#7D7D7D]">Openings:</span>
                    <span class="text-sm text-[#666] font-medium"><%= job.number_of_openings %></span>
                  </div>
                </div>
                <div class="flex items-center gap-6">
                  <.button variant="outline" size="lg">
                    Save
                  </.button>
                  <.button variant="primary" size="lg">
                    Apply Now
                  </.button>
                </div>
              </div>
              <div class="border-t-[1px] border-solid border-[#EBEBEB] px-6 pb-8 pt-10">
                <span class="text-2xl font-medium text-[#171717]">About the role</span>
                <div class="w-11/12 pt-4 ">
                  <p class="text-[#666666] text-base leading-normal">
                    <%= job.overview %>
                  </p>
                </div>
              </div>
              <div class="border-t-[1px] border-solid border-[#EBEBEB] px-6 pb-8 pt-10">
                <span class="text-2xl font-medium text-[#171717]">What you will do</span>
                <div class="w-11/12 pt-4 ">
                  <%= job.description %>
                </div>
              </div>

              <div class="border-t-[1px] border-solid border-[#EBEBEB] px-6 pb-8 pt-10">
                <span class="text-2xl font-medium text-[#171717]">About you</span>
                <div class="w-11/12 pt-4 ">
                  <ul class="list-disc pl-10 space-y-4">
                    <li class="text-[#666666] text-base leading-normal">
                      <strong class="font-medium text-[#171717]"><em>3+ years of relevant experience </em></strong>in supporting the audit lifecycle in a cloud-centric environment (SOC 2, ISO 27001, PCI, HIPAA, etc.) with strong organizational skills to be flexible and proactive in a high-growth, start-up environment
                    </li>

                    <li class="text-[#666666] text-base leading-normal">
                      Experience collaborating closely with internal partners to seamlessly incorporate policies and technical controls into the SDLC.
                    </li>

                    <li class="text-[#666666] text-base leading-normal">
                      Strong project management skills and sense of ownership with the ability to communicate and collaborate effectively, and execute projects across various business units and levels.
                    </li>
                  </ul>
                </div>
              </div>
              <div class="border-t-[1px] border-solid border-[#EBEBEB] px-6 pb-8 pt-10">
                <span class="text-2xl font-medium text-[#171717]">Bonus if you have</span>
                <div class="w-11/12 pt-4 ">
                  <ul class="list-disc pl-10 space-y-4">
                    <li class="text-[#666666] text-base leading-normal">
                      <strong class="font-medium text-[#171717]"><em>3+ years of relevant experience </em></strong>in supporting the audit lifecycle in a cloud-centric environment (SOC 2, ISO 27001, PCI, HIPAA, etc.) with strong organizational skills to be flexible and proactive in a high-growth, start-up environment
                    </li>

                    <li class="text-[#666666] text-base leading-normal">
                      Experience collaborating closely with internal partners to seamlessly incorporate policies and technical controls into the SDLC.
                    </li>

                    <li class="text-[#666666] text-base leading-normal">
                      Strong project management skills and sense of ownership with the ability to communicate and collaborate effectively, and execute projects across various business units and levels.
                    </li>
                  </ul>
                </div>
              </div>
              <div class="border-t-[1px] border-solid border-[#EBEBEB] px-6 pb-8 pt-10">
                <span class="text-2xl font-medium text-[#171717]">Benefits</span>
                <div class="w-11/12 pt-4 ">
                  <%= job.benefits %>
                </div>
              </div>
              <div class="border-t-[1px] border-solid  border-[#EBEBEB] px-6 pb-8 pt-10 bg-white">
                <div class="space-y-4">
                  <span class="text-3xl font-semibold text-[#171717]">Apply Now</span>
                  <p class="text-[#666666] text-base leading-normal">
                    Share something about you, what you're looking for, or why this role interests you.
                  </p>
                </div>
                <div class="pt-10 pb-8">
                  <.input
                    field="klasjfd"
                    name="kljdf"
                    value="ksjfkd"
                    type="textarea"
                    label="I would be a fit as:"
                    rows="5"
                    placeholder="Enter the job description"
                    required
                  />
                </div>
                <div>
                  <div class="flex items-center justify-end">
                    <.button variant="primary" size="default">
                      Submit application
                    </.button>
                  </div>
                </div>
              </div>
              <div></div>
            </div>
            <div class="col-span-2 ">
              <div class="sticky top-24 space-y-6">
                <article class="p-6 border-[1px] border-solid border-[#E6E6E6] flex flex-col gap-8">
                  <div class="bg-[#FFF] relative rounded-full h-10 w-10 grid place-content-center overflow-hidden  border-[1px] border-solid border-[#EBEBEB]">
                    <img
                      src="https://cdn2.hubspot.net/hubfs/53/image8-2.jpg"
                      class=" absolute inset-0  object-center object-cover h-full w-full"
                    />
                  </div>
                  <div class="flex flex-col gap-3 pt-4 ">
                    <span class="text-xl font-medium text-[#171717]">Google India Inc</span>
                    <span class="text-sm  text-[#666666]">
                      we are aiming to make something good. something which is based out of exilir and good stuff.
                    </span>
                  </div>

                  <div class="flex items-center gap-4">
                    <a
                      href={~p"/@client.id"}
                      class="text-[#0068D6]  flex items-end gap-2 text-sm underline-offset-4 cursor-pointer "
                    >
                      Know more about company<svg
                        class="inline-block -translate-x-1"
                        data-testid="geist-icon"
                        height="16"
                        stroke-linejoin="round"
                        style="color:currentColor"
                        viewBox="0 0 16 16"
                        width="16"
                      ><path
                          fill-rule="evenodd"
                          clip-rule="evenodd"
                          d="M6.75011 4H6.00011V5.5H6.75011H9.43945L5.46978 9.46967L4.93945 10L6.00011 11.0607L6.53044 10.5303L10.499 6.56182V9.25V10H11.999V9.25V5C11.999 4.44772 11.5512 4 10.999 4H6.75011Z"
                          fill="currentColor"
                        ></path></svg>
                    </a>
                  </div>
                </article>
                <article class="p-6 border-[1px] border-solid border-[#E6E6E6] flex flex-col gap-8">
                  <div class="bg-[#FFF] rounded-full h-10 w-10 grid place-content-center  border-[1px] border-solid border-[#EBEBEB]">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke-width="1.5"
                      stroke="#666"
                      class="size-6"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
                      />
                    </svg>
                  </div>
                  <div class="flex flex-col gap-3 pt-4 ">
                    <span class="text-xl font-medium text-[#171717]">
                      Safety tips for your job search
                    </span>
                    <span class="text-sm  text-[#666666]">
                      How you can be safe while applying for a role and how should you choose a job role.
                    </span>
                  </div>

                  <div class="flex items-center gap-4">
                    <div class="max-h-[32px] min-h-[32px]  max-w-[32px] min-w-[32px] rounded-full overflow-hidden">
                      <img
                        src="https://rakesh-gupta29.github.io/profile.jpeg"
                        class="object-center object-cover h-full w-full"
                        alt="profile for Rakesh Gupta"
                      />
                    </div>
                    <span class="text-sm  text-[#666666]">Rakesh Gupta</span>
                  </div>
                </article>
              </div>
            </div>
          </div>
        </section>
      </.async_result>
    </section>
    """
  end
end
