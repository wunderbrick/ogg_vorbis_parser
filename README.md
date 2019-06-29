# OggVorbisParser [![hex.pm version][hex-badge]][hex-url]

A parser for VorbisComments in Ogg containers.

## Installation

The package can be installed by adding `ogg_vorbis_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ogg_vorbis_parser, "~> 0.1.0"}
  ]
end
```

## Examples
  ```elixir
  iex> {:ok, binary} = OggVorbisParser.parse("test/audio_files/lifeandtimesoffrederickdouglass_01_douglass.ogg")
  iex> binary
  %{
    comments: [
      ["encoder", "Lavc55.68.101 libvorbis"],
      ["artist", "Frederick Douglass"],
      ["genre", "speech"],
      ["title", "01 - Author's Birth"],
      ["album", "Life and Times of Frederick Douglass"],
      ["TRACKNUMBER", "2"],
      ["encoder", "Lavf55.45.100"],
      ["mtime", "1415249910"],
      ["size", "5632957"],
      ["md5", "4be053d1a643c55f155bc489e687f9c8"],
      ["crc32", "965da915"],
      ["sha1", "f85622a5998dde20e935fbcee782fcb39bbcdaa6"],
      ["format", "128Kbps MP3"],
      ["length", "351.76"],
      ["height", "0"],
      ["width", "0"],
      ["source", "original"],
      ["comment",
       "http://archive.org/details/life_times_frederick_douglass_ls_1411_librivox"]
    ],
    vendor_string: "Lavf55.45.100"
  }

  iex> {:error, err} = OggVorbisParser.parse("test/audio_files/lifeandtimesoffrederickdouglass_01_douglass_128kb.mp3")
  iex> err
  :no_ogg_container_found
  ```

  [hex-url]: https://hex.pm/packages/ogg_vorbis_parser
  [hex-badge]: https://img.shields.io/hexpm/v/ogg_vorbis_parser.svg
