defmodule OggVorbisParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :ogg_vorbis_parser,
      name: "OggVorbisParser",
      description: description(),
      licenses: "MIT License",
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Parses VorbisComments in Ogg Vorbis files."
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
