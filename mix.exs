defmodule Transpiler.MixProject do
  use Mix.Project

  def project do
    [
      app: :transpiler,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :wx],
      mod: {Transpiler.Application, []}
    ]
  end

  defp escript do
    [main_module: Transpiler.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, " ~> 1.4.5", runtime: false, only: [:dev]},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:vega_lite, "~> 0.1.11"}
      # {:livebook, "~> 0.12.1"}
    ]
  end
end
