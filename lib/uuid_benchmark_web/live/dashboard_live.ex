defmodule UuidBenchmarkWeb.DashboardLive do
  use UuidBenchmarkWeb, :live_view
  alias UuidBenchmark.Analytics

  # 1. MOUNT
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(UuidBenchmark.PubSub, "dashboard_logs")

    {:ok,
     socket
     |> assign(loading: false, results: nil) # <--- This initializes the keys so they are found
     |> stream(:logs, [], dom_id: &"log-#{&1.id}")}
  end

  # 2. RENDER
  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-6xl mx-auto font-sans">

      <div class="text-center mb-10">
        <h1 class="text-4xl font-extrabold text-gray-800 mb-4">UUID v4 vs v7 Showdown</h1>
        <p class="text-gray-500 mb-6">Inserting <strong>100,000</strong> users into Postgres</p>

        <button phx-click="run_benchmark" disabled={@loading}
          class={"px-8 py-3 rounded-full text-white font-bold text-lg shadow-lg transition transform hover:scale-105 " <>
          if(@loading, do: "bg-gray-400 cursor-not-allowed", else: "bg-indigo-600 hover:bg-indigo-700")}>
          <%= if @loading, do: "Running Benchmark...", else: "🔥 Start Battle" %>
        </button>
      </div>

      <div :if={@results} class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10 animate-fade-in">
        <div class="bg-red-50 border border-red-200 rounded-xl p-6 text-center shadow-sm">
          <h3 class="text-red-800 font-bold uppercase tracking-wider text-sm">UUID v4 (Random)</h3>
          <p class="text-4xl font-black text-gray-800 mt-2"><%= Float.round(@results.v4_time, 2) %> <span class="text-lg text-gray-500">ms</span></p>
        </div>

        <div class="bg-green-50 border border-green-200 rounded-xl p-6 text-center shadow-sm">
          <h3 class="text-green-800 font-bold uppercase tracking-wider text-sm">UUID v7 (Ordered)</h3>
          <p class="text-4xl font-black text-gray-800 mt-2"><%= Float.round(@results.v7_time, 2) %> <span class="text-lg text-gray-500">ms</span></p>
        </div>

        <div class="bg-gray-900 rounded-xl p-6 text-center shadow-lg transform scale-105 ring-4 ring-indigo-100">
          <h3 class="text-gray-400 font-bold uppercase tracking-wider text-sm">Performance Gain</h3>
          <p class="text-4xl font-black text-red-500 mt-2">
             +<%= Float.round(@results.diff, 2) %> <span class="text-lg text-gray-500">ms</span>
          </p>
          <p class="text-xs text-gray-400 mt-1">v7 is faster</p>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-md border border-gray-200 overflow-hidden">
        <div class="bg-gray-50 px-4 py-3 border-b border-gray-200 flex justify-between items-center">
          <h3 class="font-bold text-gray-700">Real-time Transaction Logs</h3>
          <span class="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full animate-pulse">Live</span>
        </div>

        <div id="logs-container" class="h-64 overflow-y-auto p-4 bg-gray-50 font-mono text-sm" phx-update="stream">
          <div :for={{id, log} <- @streams.logs} id={id} class="mb-2 p-2 bg-white rounded shadow-sm border-l-4 border-indigo-500 flex justify-between items-center">
            <span class="font-bold text-gray-700"><%= log.message %></span>
            <span class="text-xs text-gray-400"><%= log.uuid %></span>
          </div>
        </div>
      </div>

    </div>
    """
  end

  # 3. HANDLERS
  def handle_event("run_benchmark", _params, socket) do
    send(self(), :execute_benchmark)
    {:noreply,
     socket
     |> assign(loading: true, results: nil)
     |> stream(:logs, [], reset: true)}
  end

  def handle_info(:execute_benchmark, socket) do
    results = UuidBenchmark.BenchmarkEngine.run_comparison()
    {:noreply, assign(socket, loading: false, results: results)}
  end

  def handle_info({:new_log, log}, socket) do
    {:noreply, stream_insert(socket, :logs, log, at: 0)}
  end
end
