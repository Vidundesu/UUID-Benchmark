defmodule UuidBenchmark.BenchmarkEngine do
  import Ecto.Query
  alias UuidBenchmark.Repo
  alias UuidBenchmark.Benchmarks.{UserV4, UserV7}
  alias UuidBenchmark.Analytics

  @batch_size 5_000
  @total_count 100_000
  @read_count 10_000 # How many selects to perform

  # --- INSERT BENCHMARK ---
  def run_comparison do
    Analytics.create_log(%{message: "🧹 Cleaning database...", uuid: Ecto.UUID.generate()})
    Repo.delete_all(UserV4)
    Repo.delete_all(UserV7)

    Analytics.create_log(%{message: "🏁 Starting UUID v4 Insert...", uuid: Ecto.UUID.generate()})
    {time_v4, _} = :timer.tc(fn -> insert_records(:v4) end)

    Analytics.create_log(%{message: "🏁 Starting UUID v7 Insert...", uuid: Ecto.UUID.generate()})
    {time_v7, _} = :timer.tc(fn -> insert_records(:v7) end)

    %{
      v4_time: time_v4 / 1000,
      v7_time: time_v7 / 1000,
      diff: (time_v4 - time_v7) / 1000
    }
  end

  # --- READ BENCHMARK (NEW) ---
  def run_read_comparison do
    # 1. Preparation (Not timed) - Fetch random IDs to query later
    Analytics.create_log(%{message: "📋 Pre-fetching #{@read_count} random IDs...", uuid: Ecto.UUID.generate()})
    v4_ids = Repo.all(from u in UserV4, select: u.id, order_by: fragment("RANDOM()"), limit: ^@read_count)
    v7_ids = Repo.all(from u in UserV7, select: u.id, order_by: fragment("RANDOM()"), limit: ^@read_count)

    # 2. Run V4 Reads
    Analytics.create_log(%{message: "📖 Executing #{@read_count} SELECTs on UUID v4...", uuid: Ecto.UUID.generate()})
    {time_v4, _} = :timer.tc(fn -> read_loop(UserV4, v4_ids) end)

    # 3. Run V7 Reads
    Analytics.create_log(%{message: "📖 Executing #{@read_count} SELECTs on UUID v7...", uuid: Ecto.UUID.generate()})
    {time_v7, _} = :timer.tc(fn -> read_loop(UserV7, v7_ids) end)

    %{
      v4_time: time_v4 / 1000,
      v7_time: time_v7 / 1000,
      diff: (time_v4 - time_v7) / 1000
    }
  end

  # --- HELPERS ---

  defp insert_records(type) do
    schema = if type == :v4, do: UserV4, else: UserV7

    1..@total_count
    |> Stream.chunk_every(@batch_size)
    |> Enum.with_index(1)
    |> Enum.each(fn {chunk, index} ->
      rows = Enum.map(chunk, fn _ -> generate_row(type) end)
      Repo.insert_all(schema, rows)

      Analytics.create_log(%{
        message: "✅ [#{String.upcase(to_string(type))}] Inserted batch #{index}",
        uuid: Ecto.UUID.generate()
      })
    end)
  end

  defp read_loop(schema, ids) do
    # Fetch records one by one to simulate API traffic
    Enum.each(ids, fn id -> Repo.get(schema, id) end)
  end

  defp generate_row(:v4), do: %{id: Ecto.UUID.generate(), name: "User v4", inserted_at: NaiveDateTime.utc_now()}
  defp generate_row(:v7), do: %{id: Uniq.UUID.uuid7(), name: "User v7", inserted_at: NaiveDateTime.utc_now()}
end
