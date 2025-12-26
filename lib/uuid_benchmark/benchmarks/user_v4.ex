defmodule UuidBenchmark.Benchmarks.UserV4 do
  use Ecto.Schema

  # UUID v4 is the default for Ecto
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users_v4" do
    field :name, :string
    field :inserted_at, :naive_datetime_usec
  end
end
