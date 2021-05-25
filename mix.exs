defmodule McModManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :mc_mod_manager,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:downstream, "~> 1.0.0"},
      {:optimus, "~> 0.2"}
    ]
  end

  def escript do
    [main_module: McModManager.CLI, name: "mmm"]
  end

end
