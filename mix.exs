defmodule OggVorbisParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :ogg_vorbis_parser,
      name: "OggVorbisParser",
      source_url: "https://github.com/wunderbrick/ogg_vorbis_parser",
      description: description(),
      package: package(),
      version: "1.0.0",
      elixir: "~> 1.9",
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

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/wunderbrick/ogg_vorbis_parser"}
    ]
  end

  defp deps do
    [{:ex_doc, "~> 0.21.2", only: :dev, runtime: false}]
  end
end
