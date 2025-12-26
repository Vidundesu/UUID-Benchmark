defmodule UuidBenchmark.Repo.Migrations.CreateBenchmarkTables do
  use Ecto.Migration

  def change do
    # Table 1: Standard Random UUID (v4)
    create table(:users_v4, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :inserted_at, :naive_datetime_usec # standard timestamp
    end

    # Table 2: Time-Ordered UUID (v7)
    create table(:users_v7, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      # Note: We don't technically need inserted_at for v7 sorting,
      # but we keep it to make the tables identical structures.
      add :inserted_at, :naive_datetime_usec
    end
  end
end
