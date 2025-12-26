defmodule UuidBenchmark.BenchmarkEngine do
  alias UuidBenchmark.Repo
  alias UuidBenchmark.Benchmarks.{UserV4, UserV7}
  alias UuidBenchmark.Analytics

  @batch_size 5_000
  @total_count 1_000_000

  def run_comparison do
    # 1. Cleanup
    Analytics.create_log(%{message: "🧹 Cleaning database...", uuid: Ecto.UUID.generate()})
    Repo.delete_all(UserV4)
    Repo.delete_all(UserV7)

    # 2. Run V4
    Analytics.create_log(%{message: "🏁 Starting UUID v4 Benchmark...", uuid: Ecto.UUID.generate()})
    {time_v4, _} = :timer.tc(fn -> insert_records(:v4) end)

    # 3. Run V7
    Analytics.create_log(%{message: "🏁 Starting UUID v7 Benchmark...", uuid: Ecto.UUID.generate()})
    {time_v7, _} = :timer.tc(fn -> insert_records(:v7) end)

    # 4. Return Results (Using the keys the Dashboard expects)
    %{
      v4_time: time_v4 / 1000,
      v7_time: time_v7 / 1000,
      diff: (time_v4 - time_v7) / 1000
    }
  end

  defp insert_records(type) do
    schema = if type == :v4, do: UserV4, else: UserV7

    1..@total_count
    |> Stream.chunk_every(@batch_size)
    |> Enum.with_index(1)
    |> Enum.each(fn {chunk, index} ->
      # A. Generate Data
      rows = Enum.map(chunk, fn _ -> generate_row(type) end)

      # B. Insert into DB
      Repo.insert_all(schema, rows)

      # C. Broadcast Log
      Analytics.create_log(%{
        message: "✅ [#{String.upcase(to_string(type))}] Inserted batch #{index} (#{@batch_size} users)",
        uuid: Ecto.UUID.generate()
      })
    end)
  end

  defp generate_row(:v4) do
    %{
      id: Ecto.UUID.generate(),
      name: "User v4",
      inserted_at: NaiveDateTime.utc_now()
    }
  end

  defp generate_row(:v7) do
    %{
      id: Uniq.UUID.uuid7(),
      name: "User v7",
      inserted_at: NaiveDateTime.utc_now()
    }
  end
end
