defmodule OggVorbisParserTest do
  use ExUnit.Case
  doctest OggVorbisParser

  setup_all do
    OggVorbisParser.parse("test/audio_files/lifeandtimesoffrederickdouglass_01_douglass.ogg")
  end

  test "Ogg capture pattern" do
    {:ok, binary} = File.read("test/audio_files/lifeandtimesoffrederickdouglass_01_douglass.ogg")

    <<
      capture_pattern::binary-size(4),
      _rest::binary
    >> = binary

    assert capture_pattern == "OggS"
  end

  test "VorbisComment", state do
    assert state["comments"] ==
             %{
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
             }

    assert state["vendor_string"] == "Lavf55.45.100"
  end

  test "mp3" do
    {:ok, binary} =
      File.read("test/audio_files/lifeandtimesoffrederickdouglass_01_douglass_128kb.mp3")

    <<
      capture_pattern::binary-size(4),
      _rest::binary
    >> = binary

    assert capture_pattern != "OggS"
  end

  test "parse mp3" do
    assert OggVorbisParser.parse(
             "test/audio_files/lifeandtimesoffrederickdouglass_01_douglass_128kb.mp3"
           ) == {:error, :no_ogg_container_found}
  end
end
