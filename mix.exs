defmodule OpenAi.MixProject do
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
      mod: {OpenAi, []},
      applications: [:logger, :jason, :tesla],
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    community-maintained OpenAi API Wrapper written in Elixir.
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
      {:tesla, "~> 1.5"},
      {:hackney, "~> 1.17"},
      {:mock, "~> 0.3.6"},
      {:mix_test_watch, "~> 1.0"},
      {:ex_doc, "~> 0.29.2", only: :dev},
      # * Code quality
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
