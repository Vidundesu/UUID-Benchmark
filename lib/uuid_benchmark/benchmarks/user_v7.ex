defmodule UuidBenchmark.Benchmarks.UserV7 do
  use Ecto.Schema

  # We tell Ecto NOT to autogenerate, because we will supply the v7 ID manually
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "users_v7" do
    field :name, :string
    field :inserted_at, :naive_datetime_usec
  end
end
