# OggVorbisParser [![hex.pm version][hex-badge]][hex-url]

A parser for VorbisComments in Ogg containers.

## Installation

The package can be installed by adding `ogg_vorbis_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ogg_vorbis_parser, "~> 2.0.0"}
  ]
end
```

This parser only loads 4000 byte chunks into memory by default (xiph.org's recommended max for streaming). You can pass in more bytes if you need to though.

Note that the "format" comment in the example below says MP3 because this Ogg file from archive.org was probably converted from an mp3. The actual mp3 is included too as shown below.

## Examples
  ```elixir
  iex> {:ok, binary} = OggVorbisParser.parse("test/audio_files/lifeandtimesoffrederickdouglass_01_douglass.ogg")
  iex> binary
  %{
    "comments" => %{
      "album" => "Life and Times of Frederick Douglass",
      "artist" => "Frederick Douglass",
      "comment" =>
        "http://archive.org/details/life_times_frederick_douglass_ls_1411_librivox",
      "crc32" => "965da915",
      "encoder" => "Lavf55.45.100",
      "format" => "128Kbps MP3",
      "genre" => "speech",
      "height" => "0",
      "length" => "351.76",
      "md5" => "4be053d1a643c55f155bc489e687f9c8",
      "mtime" => "1415249910",
      "sha1" => "f85622a5998dde20e935fbcee782fcb39bbcdaa6",
      "size" => "5632957",
      "source" => "original",
      "title" => "01 - Author's Birth",
      "tracknumber" => "2",
      "vendor_string" => "Lavf55.45.100",
      "width" => "0"
    },
    "vendor_string" => "Lavf55.45.100"
  }

  iex> {:ok, binary} = OggVorbisParser.parse("test/audio_files/lifeandtimesoffrederickdouglass_01_douglass.ogg")
  iex> binary["comments"]["title"]
  "01 - Author's Birth"

  iex> {:error, err} = OggVorbisParser.parse("test/audio_files/lifeandtimesoffrederickdouglass_01_douglass_128kb.mp3")
  iex> err
  :no_ogg_container_found
  ```

  [hex-url]: https://hex.pm/packages/ogg_vorbis_parser
  [hex-badge]: https://img.shields.io/hexpm/v/ogg_vorbis_parser.svg
