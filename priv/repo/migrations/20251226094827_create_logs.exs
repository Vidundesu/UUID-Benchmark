defmodule UuidBenchmark.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :message, :string
      add :uuid, :uuid

      timestamps(type: :utc_datetime)
    end
  end
end
