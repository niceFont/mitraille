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
#refactor this
  def digest_results(:success, successes) do
    successes
    |> Enum.reduce(%{}, fn {_, code, _}, acc ->
        Map.update(acc, code, 1, fn v -> v + 1 end)
     end)
    |> Enum.each(fn {k, v} -> IO.puts("Status: #{k} --> #{v} times") end)

  end
  def digest_results(:fail, fails) do
    fails
    |> Enum.reduce(%{}, fn {_, code, _}, acc ->
        Map.update(acc, code, 1, fn v -> v + 1 end)
     end)
    |> Enum.each(fn {k, v} -> IO.puts("Status: #{k} --> #{v} times") end)
  end

  def extract_type({:ok,{ time,{type, code, body}}}) do
    extract_type({time, {type, code, body}})
  end

  def extract_type({_,{type, code, body }}) do
    {type, code, body}
  end


  def extract_time({:ok, {time, _}}) do
    time
  end
  def extract_time({time, _}) do
    time
  end

  def calculate_benchmarks(benchmark, results) do
    times = Enum.map(results, &extract_time/1)
    {min, max} = Enum.min_max(times)
    median = times
    |> Enum.sort()
    |> Enum.at(trunc(length(times) / 2))
    IO.puts("Min: #{min}s")
    IO.puts("Max: #{max}s")
    IO.puts("Median: #{median}s")
    IO.puts("Total: #{benchmark.total_time}s")
    {fails, successes} = results
    |> Enum.map(&extract_type/1)
    |> Enum.split_with(fn {type, _, _} -> type == :fail end)

    digest_results(:success, successes)
    digest_results(:fail, fails)
  end
end
