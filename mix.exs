defmodule Openai.MixProject do
  use Mix.Project

  def project do
    [
      app: :openai,
      version: "0.3.1",
      elixir: "~> 1.11",
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "openai.ex",
      source_url: "https://github.com/mgallo/openai.ex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {OpenAI, []},
      applications: [:httpoison, :json, :logger],
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    community-maintained OpenAI API Wrapper written in Elixir.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      exclude_patterns: ["./config/*"],
      links: %{
        "GitHub" => "https://github.com/mgallo/openai.ex"
      },
      maintainers: [
        "mgallo"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:json, "~> 1.4"},
      {:httpoison, "~> 1.8"},
      {:mock, "~> 0.3.6"},
      {:mix_test_watch, "~> 1.0"},
      {:ex_doc, ">= 0.29.3", only: :dev}
    ]
  end
end
