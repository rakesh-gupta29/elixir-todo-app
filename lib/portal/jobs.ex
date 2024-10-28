defmodule Portal.Jobs do
  @moduledoc """
  Context for jobs.
  """
  import Ecto.Query, warn: false

  alias Portal.Repo
  alias Portal.Jobs.Job

  def get_all_jobs(client_id) do
    Job
    |> where(client_id: ^client_id)
    |> Repo.all()
  end

  def job_with_id(id) do
    Job |> Repo.get(id)
  end

  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end
end
