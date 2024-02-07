defmodule VmsServer.Repo do
  use Ecto.Repo,
    otp_app: :vms_server,
    adapter: Ecto.Adapters.Postgres
end
