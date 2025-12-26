defmodule UuidBenchmarkWeb.DashboardLive do
  use UuidBenchmarkWeb, :live_view
  alias UuidBenchmark.Analytics

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(UuidBenchmark.PubSub, "dashboard_logs")

    {:ok,
     socket
     |> assign(loading: false, insert_results: nil, read_results: nil)
     |> stream(:logs, [], dom_id: &"log-#{&1.id}")}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-6xl mx-auto font-sans">

      <div class="text-center mb-10">
        <h1 class="text-4xl font-extrabold text-gray-800 mb-4">UUID v4 vs v7 Showdown</h1>

        <div class="flex justify-center gap-4">
          <button phx-click="run_insert" disabled={@loading}
            class={"px-6 py-3 rounded-full text-white font-bold shadow-lg transition transform hover:scale-105 " <>
            if(@loading, do: "bg-gray-400", else: "bg-indigo-600 hover:bg-indigo-700")}>
            🚀 Test Write Speed (Insert)
          </button>

          <button phx-click="run_read" disabled={@loading}
            class={"px-6 py-3 rounded-full text-white font-bold shadow-lg transition transform hover:scale-105 " <>
            if(@loading, do: "bg-gray-400", else: "bg-teal-600 hover:bg-teal-700")}>
            🔍 Test Read Speed (Select)
          </button>
        </div>
      </div>

      <div :if={@insert_results} class="mb-10 animate-fade-in">
        <h2 class="text-2xl font-bold text-indigo-900 mb-4">✍️ Write Results (100k Rows)</h2>
        <%= result_grid(assigns, @insert_results) %>
      </div>

      <div :if={@read_results} class="mb-10 animate-fade-in">
        <h2 class="text-2xl font-bold text-teal-900 mb-4">📖 Read Results (5k Lookups)</h2>
        <%= result_grid(assigns, @read_results) %>
      </div>

      <div class="bg-white rounded-lg shadow-md border border-gray-200 overflow-hidden">
        <div class="bg-gray-50 px-4 py-3 border-b border-gray-200 flex justify-between items-center">
          <h3 class="font-bold text-gray-700">Real-time Logs</h3>
          <span class="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full animate-pulse">Live</span>
        </div>
        <div id="logs-container" class="h-64 overflow-y-auto p-4 bg-gray-50 font-mono text-sm" phx-update="stream">
          <div :for={{id, log} <- @streams.logs} id={id} class="mb-2 p-2 bg-white rounded shadow-sm border-l-4 border-gray-400 flex justify-between">
            <span class="font-bold text-gray-700"><%= log.message %></span>
            <span class="text-xs text-gray-400"><%= log.uuid %></span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Reusable Component for Result Cards
  def result_grid(assigns, results) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-red-50 border border-red-200 rounded-xl p-6 text-center shadow-sm">
        <h3 class="text-red-800 font-bold text-sm">UUID v4</h3>
        <p class="text-4xl font-black text-gray-800 mt-2"><%= Float.round(results.v4_time, 2) %> <span class="text-lg text-gray-500">ms</span></p>
      </div>
      <div class="bg-green-50 border border-green-200 rounded-xl p-6 text-center shadow-sm">
        <h3 class="text-green-800 font-bold text-sm">UUID v7</h3>
        <p class="text-4xl font-black text-gray-800 mt-2"><%= Float.round(results.v7_time, 2) %> <span class="text-lg text-gray-500">ms</span></p>
      </div>
      <div class="bg-gray-900 rounded-xl p-6 text-center shadow-lg ring-4 ring-indigo-100">
        <h3 class="text-gray-400 font-bold text-sm">Difference</h3>
        <p class="text-4xl font-black text-yellow-400 mt-2"><%= Float.round(results.diff, 2) %> <span class="text-lg text-gray-500">ms</span></p>
      </div>
    </div>
    """
  end

  # --- EVENTS ---
  def handle_event("run_insert", _params, socket) do
    send(self(), :exec_insert)
    {:noreply, assign(socket, loading: true, insert_results: nil) |> stream(:logs, [], reset: true)}
  end

  def handle_event("run_read", _params, socket) do
    send(self(), :exec_read)
    {:noreply, assign(socket, loading: true, read_results: nil) |> stream(:logs, [], reset: true)}
  end

  def handle_info(:exec_insert, socket) do
    results = UuidBenchmark.BenchmarkEngine.run_comparison()
    {:noreply, assign(socket, loading: false, insert_results: results)}
  end

  def handle_info(:exec_read, socket) do
    results = UuidBenchmark.BenchmarkEngine.run_read_comparison()
    {:noreply, assign(socket, loading: false, read_results: results)}
  end

  def handle_info({:new_log, log}, socket) do
    {:noreply, stream_insert(socket, :logs, log, at: 0)}
  end
end
