defmodule UuidBenchmark.AnalyticsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UuidBenchmark.Analytics` context.
  """

  @doc """
  Generate a log.
  """
  def log_fixture(attrs \\ %{}) do
    {:ok, log} =
      attrs
      |> Enum.into(%{
        message: "some message",
        uuid: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> UuidBenchmark.Analytics.create_log()

    log
  end
end
