defmodule PortalWeb.AuthClients.RegisterLive do
  @moduledoc """
  register for companies
  """

  use PortalWeb, :live_view_auth

  alias Portal.Clients.Client
  alias Portal.Clients
  import PortalWeb.UI.Button

  def mount(_params, _session, socket) do
    changeset = Clients.create_client_account_changeset(%Client{})

    {:ok,
     socket
     |> assign(:password_visible, false)
     |> assign(:title, "Get started with free trial")
     |> assign(trigger_submit: false, check_errors: false)
     |> assign_form(changeset)}
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset, as: "client")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  def handle_event("validate", %{"client" => client_params}, socket) do
    changeset = Clients.create_client_account_changeset(%Client{}, client_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("save", %{"client" => client_params}, socket) do
    case Clients.register_client(client_params) do
      {:ok, client} ->
        {:ok, _} =
          Clients.deliver_email_for_account_confirmation(
            client,
            &url(~p"/app/confirm/#{&1}")
          )

        changeset = Clients.create_client_account_changeset(client)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  # triggers the save event which creates the user
  # then a post req is made to the /login path which will
  # login the user.

  def render(assigns) do
    ~H"""
    <div class=" max-w-md mx-auto  px-3 md:w-11/12 ">
      <span class="text-2xl text-center px-4 block font-semibold text-brand"><%= @title %></span>
      <.simple_form
        for={@form}
        novalidate
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/app/login?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input placeholder="John Doe" field={@form[:name]} type="text" label="Name" required />
        <.input
          field={@form[:email]}
          placeholder="example@gamil.com"
          type="email"
          label="Email"
          required
        />

        <.input
          field={@form[:password]}
          type={if @password_visible, do: "text", else: "password"}
          label="Password"
          placeholder="*****"
          required
        />

        <.input
          field={@form[:password_confirmation]}
          type={if @password_visible, do: "text", else: "password"}
          label="Confirm Password"
          placeholder="******"
          required
        />
        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>

      <div class="py-6 text-center">
        <span>
          Already have an account?
          <a
            href="/app/login"
            class=" text-inherit underline font-semibold px-2 underline-offset-4 decoration-from-font"
          >
            Log in
          </a>
        </span>
      </div>

      <div class="text-center">
        <span class="text-sm">
          By continuing, you agree to our <br />
          <a
            href="/terms-and-conditions#terms"
            class=" text-inherit underline font-normal px-2 underline-offset-4 decoration-from-font hover:text-brand"
          >
            Terms of services
          </a>
          and
          <a
            href="/terms-and-conditions#privacy"
            class=" text-inherit underline font-normal px-2 underline-offset-4 decoration-from-font hover:text-brand"
          >
            Privacy policies
          </a>
        </span>
      </div>
    </div>
    """
  end
end
