defmodule UuidBenchmark.Repo do
  use Ecto.Repo,
    otp_app: :uuid_benchmark,
    adapter: Ecto.Adapters.Postgres
end
