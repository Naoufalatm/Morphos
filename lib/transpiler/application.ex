defmodule Transpiler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  @moduledoc """
  The OTP application module for the Transpiler.

  This module defines the standard OTP application callbacks for starting
  and supervising the Transpiler system. It parses command-line arguments
  (e.g., `--input`, `--output`) and then sets up the supervision tree.

  ## Examples

      iex> # Typically, you don't call start/2 manually; it's invoked by Mix/Elixir.
      iex> Transpiler.Application.start(:normal, ["--input", "file.xyz"])
      {:ok, pid_of_supervisor}

  See [Application](https://hexdocs.pm/elixir/Application.html) for more details on
  how applications are structured.
  """

  use Application

  @doc """
  Starts the Transpiler application and its supervision tree.

  This callback is invoked automatically when the application is started (for
  example, by running `mix run --no-halt`). It uses `OptionParser` to parse command-line
  arguments (e.g. `--input`, `--output`) and then starts the supervisor with a
  `:one_for_one` strategy.

  ## Parameters

    - `_type` - The type of the startup, commonly `:normal`.
    - `args`  - A list of command-line arguments passed in by the system, e.g.,
      `["--input", "foo.src", "--output", "foo.out"]`.

  ## Returns

    - `{:ok, pid}` on successful startup, where `pid` is the pid of the root supervisor.

  ## Examples

      iex> Transpiler.Application.start(:normal, ["--input", "source_file"])
      {:ok, #PID<...>}

  For more details on available options, see:
  [OptionParser](https://hexdocs.pm/elixir/OptionParser.html).
  """
  @impl true
  def start(_type, args) do
    _ =
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

    children = [
      # Starts a worker by calling: Transpiler.Worker.start_link(arg)
      # {Transpiler.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Transpiler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
