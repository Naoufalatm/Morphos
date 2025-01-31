defmodule Calculator do
  def start(numbers) do
    parent = self()

    spawn_link(fn ->
      send(parent, {:doubles, calculate_doubles(numbers)})
    end)

    spawn_link(fn ->
      send(parent, {:squares, calculate_squares(numbers)})
    end)

    collect_results([])
  end

  defp calculate_doubles(numbers), do: calculate_doubles(numbers, [])
  defp calculate_doubles([], acc), do: Enum.reverse(acc)

  defp calculate_doubles([head | tail], acc) do
    IO.inspect("Calculating double for: #{head}")
    calculate_doubles(tail, [head * 2 | acc])
  end

  defp calculate_squares(numbers), do: calculate_squares(numbers, [])
  defp calculate_squares([], acc), do: Enum.reverse(acc)

  defp calculate_squares([head | tail], acc) do
    IO.inspect("Calculating squares for: #{head}")
    calculate_squares(tail, [head * head | acc])
  end

  defp collect_results([_, _]) do
    IO.inspect("All results has been collected")
  end

  defp collect_results(done) do
    receive do
      {:doubles, result} ->
        IO.puts("Doubles: #{inspect(result)}")
        collect_results([:doubles | done])

      {:squares, result} ->
        IO.puts("Squares: #{inspect(result)}")
        collect_results([:squares | done])
    after
      5000 -> IO.puts("Timed out waiting a result")
    end
  end
end

Calculator.start([1, 2, 3, 4, 5])
