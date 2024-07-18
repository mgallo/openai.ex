defmodule OpenAI.MixProject do
  use Mix.Project

  def project do
    [
      app: :openai,
      version: "0.6.1",
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
      applications: [:httpoison, :jason, :logger],
      extra_applications: extra_applications()
    ]
  end

  defp extra_applications do
    if Mix.env() == :test do
      [:logger, :bypass]
    else
      [:logger]
    end
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
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.0"},
      {:mock, "~> 0.3.6", only: [:test]},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.29.3", only: :dev},
      {:plug, "~> 1.0", only: :test},
      {:bypass, "~> 2.1", only: :test}
    ]
  end
end
