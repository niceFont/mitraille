defmodule Mitraille do
  require Logger
  alias Mitraille.Benchmark
  @moduledoc """
  Documentation for `Mitraille`.
  """
  # response time
  # avg response time
  # max response time
  # min response time
  # errors
  @doc """
  Hello world.

  ## Examples

      iex> Mitraille.hello()
      :world

  """

  def start_mitraille(destination, %{amount: amount, method: method, payload: payload}) do
    tasks = for _ <- 1..amount do
      Task.async(fn ->
        Benchmark.measure_time(fn ->
          Mitraille.HttpDispatcher.send_request(destination, method, payload)
        end)
      end)
    end
    Task.yield_many(tasks, 2000)
    |> Enum.map(fn {task, res} ->
      if is_nil(res) do
        Task.shutdown(task, :brutal_kill)
      else
        {_, result} = res
        result
      end
    end)
  end

  def start(destination, %{amount: amount, method: method, payload: payload}) do
    benchmark = Benchmark.init(amount)
    benchmark = Benchmark.start_timer(benchmark)
    results = start_mitraille(destination, %{amount: amount, method: method, payload: payload})
    benchmark = Benchmark.end_timer(benchmark)
    Benchmark.calculate_benchmarks(benchmark, results)
  end
end
