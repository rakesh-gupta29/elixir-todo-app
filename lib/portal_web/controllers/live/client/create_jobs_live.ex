defmodule PortalWeb.ClientLive.CreateJobLive do
  @moduledoc """
  Lets the client create a new job.
  """

  use PortalWeb, :live_view_client
  import PortalWeb.UI.Button

  alias Portal.Jobs.Job

  def mount(_params, _session, socket) do
    # Define dummy data for the job
    dummy_job_params = %{
      "title" => "Golang Developer",
      "description" => "We are looking for an experienced Golang developer...",
      "overview" => "Join our team to work on cutting-edge projects...",
      "skills" => "Golang, Microservices, REST APIs, Docker, Kubernetes",
      "notice_period" => "30 days",
      "employment_type" => "full time",
      "locations" => "Remote, San Francisco",
      "is_remote" => true,
      "min_experience" => 3,
      "max_experience" => 5,
      "education" => "Bachelor's Degree in Computer Science or related field",
      "currency" => "USD",
      "min_salary" => 80000,
      "max_salary" => 120_000,
      "negotiable" => true,
      "is_salary_disclosed" => true,
      "application_deadline" => Date.utc_today() |> Date.add(30) |> Date.to_iso8601(),
      "number_of_openings" => 2,
      "benefits" => "Health insurance, 401k matching, Flexible hours"
    }

    changeset = Job.changeset(%Job{}, dummy_job_params)

    {:ok,
     socket
     |> assign(:client_id, socket.assigns.current_client.id)
     |> assign(:form, to_form(changeset, as: "create_new_job"))}
  end

  def handle_event("validate", %{"create_new_job" => form_params}, socket) do
    changeset = Job.changeset(%Job{}, form_params)

    {:noreply,
     socket
     |> assign(:form, to_form(Map.put(changeset, :action, :validate), as: "create_new_job"))}
  end

  def handle_event("save", %{"create_new_job" => params}, socket) do
    params = Map.put(params, "client_id", socket.assigns.client_id)

    case Portal.Jobs.create_job(params) do
      {:ok, _job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Job created successfully.")
         |> redirect(to: ~p"/app/jobs")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> push_event("invalid_form", %{})
         |> assign(:form, to_form(Map.put(changeset, :action, :insert), as: "create_new_job"))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="blade-top-padding-lg blade-bottom-padding-lg">
      <div class="text-center px-3 grid place-content-center gap-1 pb-16">
        <span class="text-2xl font-semibold capitalize ">Create a job</span>
        <span>It will be listed on the microsite page</span>
      </div>
      <div class="max-w-xl mx-auto w-full md:w-11/12">
        <div class="create-jobs-form">
          <.simple_form
            for={@form}
            novalidate
            id="create_new_job"
            phx-change="validate"
            phx-submit="save"
            phx-hook="FocusFirstError"
          >
            <.input
              placeholder="Sales head"
              field={@form[:title]}
              type="text"
              label="Job Title"
              required
            />

            <.input
              field={@form[:description]}
              type="textarea"
              label="Job Description"
              rows="5"
              placeholder="Enter the job description"
              required
            />

            <.input
              field={@form[:overview]}
              type="textarea"
              label="Job Overview"
              rows="3"
              placeholder="Enter a brief overview of the job"
            />

            <.input
              field={@form[:skills]}
              type="textarea"
              label="Required Skills"
              placeholder="Comma-separated list of skills"
            />

            <.input
              field={@form[:notice_period]}
              type="select"
              prompt="Select Notice Period"
              options={["Immediate", "15 days", "30 days", "45 days", "60 days", "90 days"]}
              label="Notice Period"
            />

            <.input
              field={@form[:employment_type]}
              type="select"
              label="Employment Type"
              prompt="Select Employment type"
              options={["full time", "remote", "contract", "part time", "freelance", "others"]}
              required
            />

            <div>
              <.input
                field={@form[:locations]}
                type="text"
                label="Locations"
                placeholder="Comma-separated list of locations"
              />
              <.input field={@form[:is_remote]} type="checkbox" label="Is this a Remote Job?" />
            </div>

            <div class="grid gap-6 md:grid-cols-2">
              <.input
                field={@form[:min_experience]}
                type="number"
                label="Minimum Experience (Years)"
                placeholder="e.g. 1"
                required
              />
              <.input
                field={@form[:max_experience]}
                type="number"
                label="Maximum Experience (Years)"
                placeholder="e.g. 5"
              />
            </div>

            <.input
              field={@form[:education]}
              type="text"
              label="Required Education"
              placeholder="e.g., Bachelor's Degree"
            />

            <.input
              field={@form[:currency]}
              type="select"
              label="Salary Currency"
              options={["INR", "USD"]}
              prompt="Select currency"
            />

            <div>
              <div class="grid gap-6 md:grid-cols-2">
                <.input
                  field={@form[:min_salary]}
                  type="number"
                  step="0.01"
                  label="Minimum Salary"
                  placeholder="Enter minimum salary"
                  required
                />
                <.input
                  field={@form[:max_salary]}
                  type="number"
                  step="0.01"
                  label="Maximum Salary"
                  placeholder="Enter maximum salary"
                />
              </div>
              <div class="grid grid-cols-1 md:grid-cols-1 gap-2 pt-3 pb-5">
                <.input field={@form[:negotiable]} type="checkbox" label="Is Salary Negotiable?" />
                <.input
                  field={@form[:is_salary_disclosed]}
                  type="checkbox"
                  label="Is Salary Disclosed?"
                />
              </div>
            </div>

            <.input field={@form[:application_deadline]} type="date" label="Application Deadline" />

            <.input
              field={@form[:number_of_openings]}
              type="number"
              label="Number of Openings"
              placeholder="e.g., 1"
              required
            />

            <.input
              field={@form[:benefits]}
              type="textarea"
              label="Benefits"
              rows="3"
              placeholder="Enter all benefits"
            />

            <:actions>
              <div class="w-full grid place-content-end">
                <.button phx-disable-with="Creating...">Create Job Listing</.button>
              </div>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end
end
