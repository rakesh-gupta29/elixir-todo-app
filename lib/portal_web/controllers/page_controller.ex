defmodule PortalWeb.PageController do
  use PortalWeb, :controller

  @type flash_type :: :info | :error

  @type render_options :: %{
          title: String.t(),
          description: String.t(),
          og_image: String.t() | nil,
          script_file: String.t(),
          withLayout: boolean()
        }

  # don't suffix the app name while calling it. it is done in the root file.

  @default_options %{
    title: "Home",
    description: "Welcome to portal which promotes sensible hiring",
    og_image: "/og_image.jpg",
    script_file: nil,
    withLayout: false
  }

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render_html_page(conn, :home, %{
      title: "welcome from homepage",
      description: "welcome from home page"
    })
  end

  def about(conn, _params) do
    render_html_page(conn, :about, %{title: "about"})
  end

  def solutions(conn, _params) do
    render_html_page(conn, :solutions, %{title: "solutions"})
  end

  def pricing(conn, _params) do
    render_html_page(conn, :pricing, %{title: "pricing"})
  end

  def faq(conn, _params) do
    render_html_page(conn, :faq, %{title: "faq"})
  end

  def terms_and_conditions(conn, _params) do
    render_html_page(conn, :terms_and_conditions, %{title: "terms and conditions"})
  end

  def companies(conn, _params) do
    render_html_page(conn, :companies, %{title: "list of companies who are actively hiring"})
  end

  def help_center(conn, _params) do
    render_html_page(conn, :help_center, %{title: "help center"})
  end

  def company_microsite(conn, params) do
    case Map.fetch(params, "id") do
      {:ok, id_param} when id_param != "" ->
        case Integer.parse(id_param) do
          {id, ""} ->
            case Portal.Repo.get(Portal.Clients.Client, id) do
              nil ->
                conn
                |> put_status(:not_found)
                |> assign(:withLayout, false)
                |> render(PortalWeb.ErrorHTML, "404.html")

              client ->
                jobs = Portal.Jobs.get_all_jobs(id)

                assigns = %{client: client, jobs: jobs}

                if Enum.empty?(jobs) do
                  render_html_page(
                    conn,
                    :client_microsite,
                    %{withLayout: false, title: "Client Microsite - No Jobs Available"},
                    Map.put(assigns, :no_jobs_message, "No jobs available for this client.")
                  )
                else
                  render_html_page(
                    conn,
                    :client_microsite,
                    %{withLayout: false, title: "Client Microsite"},
                    assigns
                  )
                end
            end

          _ ->
            conn
            |> put_status(:bad_request)
            |> assign(:withLayout, false)
            |> render(PortalWeb.ErrorHTML, "400.html")
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> assign(:withLayout, false)
        |> render(PortalWeb.ErrorHTML, "400.html")
    end
  end

  def job_details(conn, params) do
    case Map.fetch(params, "id") do
      {:ok, id} when id != "" ->
        case Integer.parse(id) do
          {id, ""} ->
            case Portal.Repo.get(Portal.Jobs.Job, id) do
              nil ->
                conn
                |> put_status(:not_found)
                |> assign(:withLayout, false)
                |> render(PortalWeb.ErrorHTML, "404.html")

              job ->
                assigns = %{jobs: job}

                render_html_page(
                  conn,
                  :job_detail,
                  %{withLayout: false, title: "Job detail page"},
                  assigns
                )
            end

          _ ->
            conn
            |> put_status(:bad_request)
            |> assign(:withLayout, false)
            |> render(PortalWeb.ErrorHTML, "job_invalid.html")
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> assign(:withLayout, false)
        |> render(PortalWeb.ErrorHTML, "job_invalid.html")
    end
  end

  def render_html_page(conn, template_file, opts \\ %{}, assigns \\ %{}) do
    options = Map.merge(@default_options, opts)

    conn
    |> assign_metadata(options.title, options.description, options.og_image)
    |> assign(:withLayout, options.withLayout)
    |> maybe_assign_script_file(options.script_file)
    |> render(template_file, assigns)
  end

  def assign_metadata(conn, title, desc, og_image) do
    conn
    |> assign(:page_title, title)
    |> assign(:page_description, desc)
    |> assign(:og_image, og_image)
  end

  # implement the script assign logic for client side js files.
  def maybe_assign_script_file(conn, nil), do: conn
  def maybe_assign_script_file(conn, file) when is_binary(file), do: conn
end
