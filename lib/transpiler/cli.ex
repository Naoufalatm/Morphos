defmodule Transpiler.CLI do
  @moduledoc """
  Provides a Command Line Interface (CLI) for the Transpiler application.

  This module parses command-line arguments to determine input and output paths,
  then invokes the core `Transpiler.transpile/2` functionality. The result is
  a generated C code file which is written to the specified output folder.

  ## Usage

      mix run -e 'Transpiler.CLI.main(["--input", "source_file", "--output", "out_dir"])'

  The `--input` option specifies the file to transpile, and `--output` specifies
  the output directory where the resulting C code will be written (`main.c`).
  """
  @doc """
  Entry point for the CLI.

  Accepts a list of command-line arguments (`args`), parses them to retrieve
  input and output paths, and then processes them via `process/1`.

  ## Examples

      iex> Transpiler.CLI.main(["--input", "example.src", "--output", "out"])
      # Prints "Successfully transpiled!" on success,
      # or an error message if something goes wrong.
  """
  def main(args) do
    args
    |> parse_args()
    |> process()
  end

  defp parse_args(args) do
    {opts, _word, _} =
      OptionParser.parse(args,
        strict: [
          input: :string,
          output: :string
        ],
        aliases: [
          i: :input,
          o: :output
        ]
      )

    raise_on_missing_arg(opts, :input)
    raise_on_missing_arg(opts, :output)
    opts
  end

  defp raise_on_missing_arg(opts, arg) do
    if not Keyword.has_key?(opts, arg) do
      raise OptionParser.ParseError.exception("Missing argument: #{arg}")
    end
  end

  defp process(opts) do
    with {:ok, output} <- Transpiler.transpile(opts[:input], :file),
         :ok <- write_c_folder(opts[:output], output) do
      IO.puts("Successfully transpiled!")
    else
      {:error, error} ->
        IO.puts(:stderr, error)
    end
  end

  defp write_c_folder(path, content) do
    with :ok <- File.mkdir_p(path) do
      path
      |> Path.join("main.c")
      |> File.write(content)
    end
  end
end
