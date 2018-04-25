defmodule Toybox.MixProject do
  use Mix.Project

  def project do
    [
      app: :toybox,
      version: "0.1.0",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:erlcloud, :logger, :riakc]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:erlcloud, git: "https://github.com/BillSmargiassi/erlcloud.git", tag: "r20-test-1"},
      {:riakc, "~> 2.5.0"}
    ]
  end
end
