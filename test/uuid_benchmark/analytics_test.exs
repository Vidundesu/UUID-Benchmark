defmodule UuidBenchmark.AnalyticsTest do
  use UuidBenchmark.DataCase

  alias UuidBenchmark.Analytics

  describe "logs" do
    alias UuidBenchmark.Analytics.Log

    import UuidBenchmark.AnalyticsFixtures

    @invalid_attrs %{message: nil, uuid: nil}

    test "list_logs/0 returns all logs" do
      log = log_fixture()
      assert Analytics.list_logs() == [log]
    end

    test "get_log!/1 returns the log with given id" do
      log = log_fixture()
      assert Analytics.get_log!(log.id) == log
    end

    test "create_log/1 with valid data creates a log" do
      valid_attrs = %{message: "some message", uuid: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Log{} = log} = Analytics.create_log(valid_attrs)
      assert log.message == "some message"
      assert log.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Analytics.create_log(@invalid_attrs)
    end

    test "update_log/2 with valid data updates the log" do
      log = log_fixture()
      update_attrs = %{message: "some updated message", uuid: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Log{} = log} = Analytics.update_log(log, update_attrs)
      assert log.message == "some updated message"
      assert log.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_log/2 with invalid data returns error changeset" do
      log = log_fixture()
      assert {:error, %Ecto.Changeset{}} = Analytics.update_log(log, @invalid_attrs)
      assert log == Analytics.get_log!(log.id)
    end

    test "delete_log/1 deletes the log" do
      log = log_fixture()
      assert {:ok, %Log{}} = Analytics.delete_log(log)
      assert_raise Ecto.NoResultsError, fn -> Analytics.get_log!(log.id) end
    end

    test "change_log/1 returns a log changeset" do
      log = log_fixture()
      assert %Ecto.Changeset{} = Analytics.change_log(log)
    end
  end
end
