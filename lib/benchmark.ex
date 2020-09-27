defmodule Mitraille.Benchmark do
  @enforce_keys [:total]
  defstruct total_time: 0,
  avg_time: 0,
  max: 0,
  min: 0,
  individual_times: [],
  timer_start: 0,
  timer_end: 0,
  successes: 0,
  failures: 0,
  total: 0

  def init(total) do
    %Mitraille.Benchmark{total: total}
  end
  def start_timer(benchmark) do
    %Mitraille.Benchmark{benchmark | timer_start: System.monotonic_time(:millisecond)}
  end

  def end_timer(benchmark) do
    now = System.monotonic_time(:millisecond)
    %Mitraille.Benchmark{benchmark | timer_end: now, total_time: (now - benchmark.timer_start) / 1000}
  end
  def measure_time(func) do
    start_time = System.monotonic_time(:millisecond)
    result = func.()
    end_time = System.monotonic_time(:millisecond)
    elapsed = (end_time - start_time) / 1000
    {elapsed, result}
  end

  def digest_results(:success, successes) do
    grouped = Enum.reduce(successes, %{}, fn {_, code, _}, acc ->
        Map.update(acc, code, 1, fn v -> v + 1 end)
     end)

    IO.inspect(grouped)
  end
  def digest_results(:fail, successes) do
    grouped = Enum.reduce(successes, %{}, fn {_, code, _}, acc ->
        Map.update(acc, code, 1, fn v -> v + 1 end)
     end)

    IO.inspect(grouped)
  end
  def calculate_benchmarks(benchmark, results) do
    times = Enum.map(results, fn {time, _} -> time end)
    {min, max} = Enum.min_max(times)
    median = times
    |> Enum.sort()
    |> Enum.at(trunc(length(times) / 2))

    IO.puts("Min: #{min}s")
    IO.puts("Max: #{max}s")
    IO.puts("Median: #{median}s")
    IO.puts("Total: #{benchmark.total_time}s")
    {fails, successes} = results
    |> Enum.map(fn {_, res} -> res end)
    |> Enum.split_with(fn {type, _, _} -> type == :fail end)

    digest_results(:success, successes)
    digest_results(:fail, fails)
  end
end
