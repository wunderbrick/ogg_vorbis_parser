defmodule OggVorbisParser do
  @moduledoc """
  A parser for VorbisComments in Ogg containers.

  While it's possible to use Vorbis streams without Ogg containers or with different kinds of containers,
  this parser expects Ogg. It might work for parsing the audio metadata in .ogv files, which are still Ogg containers
  with video streams and Vorbis streams, but this hasn't been tested enough.

  The relevant part of an Ogg Vorbis file starts with an Ogg capture pattern (a file signature) followed by some Ogg container bits,
  the Vorbis identification header, and the Vorbis comment header. This package uses File.stream!/3 instead of File.read/1 to avoid loading entire audio files into memory.

  OggVorbisParser looks for a comment header packet type of 3 immediately followed by the string "vorbis." This is the beginning of the comment header.

  Version 0.1.0's output wasn't very convenient so parse/1 now gives back a nested map. Convert string keys to atoms at your own risk. If you know you'll always have certain comments for your files, e.g., "artist" or "title," consider using String.to_existing_atom/1.
  """

  @doc """
  Parses VorbisComment if present. Only loads max_size_chunk_in_bytes into memory instead of the whole file. The default max_size_chunk_in_bytes is 4000 per xiph.org's recommended max header size for streaming. Adjust as needed.

  Note that the "format" comment in the example below says MP3 because this Ogg file from archive.org was probably converted from an mp3. The actual mp3 is included too as shown below.

  ## Examples

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

  """
  @spec parse(bitstring(), integer()) :: {:ok, map()} | {:error, :atom}
  def parse(bitstring, max_size_chunk_in_bytes \\ 4000) do
    # Just look for the header in this chunk and if not found return an error.
    bitstring
    |> File.stream!([], max_size_chunk_in_bytes)
    |> Enum.find(fn bitstring -> bitstring end)
    |> parse_capture_pattern()
  end

  @spec parse_capture_pattern(bitstring()) :: {:ok, map()} | {:error, :atom}
  defp parse_capture_pattern(bitstring) do
    <<
      capture_pattern::binary-size(4),
      _rest::bitstring
    >> = bitstring

    case capture_pattern do
      "OggS" ->
        find_comment_header(bitstring, 1)

      _ ->
        {:error, :no_ogg_container_found}
    end
  end

  @spec find_comment_header(bitstring(), integer()) :: {:ok, map()} | {:error, :atom}
  defp find_comment_header(bitstring, binary_size) do
    <<
      _ogg_container_and_vorbis_id_header::binary-size(binary_size),
      vorbis_comment_header_packet_type::binary-size(1),
      vorbis_string_in_comment_header::binary-size(6),
      _rest::bitstring
    >> = bitstring

    cond do
      vorbis_comment_header_packet_type == <<3>> && vorbis_string_in_comment_header == "vorbis" ->
        {rest, comment_list_length, vendor_string} =
          parse_matching_bitstring(bitstring, binary_size)

        comments =
          parse_comments(rest, [], comment_list_length)
          |> Enum.map(fn [a, b] -> {String.downcase(a), b} end)
          |> Map.new()
          |> Map.put_new("vendor_string", vendor_string)

        {:ok,
         %{
           "comments" => comments,
           "vendor_string" => vendor_string
         }}

      binary_size >= 500 ->
        # TODO: Should this number be lower?
        {:error, :no_vorbis_comment_found}

      true ->
        find_comment_header(bitstring, binary_size + 1)
    end
  end

  @spec parse_matching_bitstring(bitstring(), integer()) :: {bitstring(), integer(), binary()}
  defp parse_matching_bitstring(bitstring, binary_size) do
    <<
      _ogg_container_and_vorbis_id_header::binary-size(binary_size),
      _vorbis_comment_header_packet_type::binary-size(1),
      _vorbis_string_in_comment_header::binary-size(6),
      vendor_length::little-integer-size(32),
      vendor_string::binary-size(vendor_length),
      comment_list_length::little-integer-size(32),
      rest::bitstring
    >> = bitstring

    {rest, comment_list_length, vendor_string}
  end

  @spec parse_comments(bitstring(), list(), integer()) :: list()
  defp parse_comments(bitstring, comments, total_comments) do
    <<
      comment_length::little-integer-size(32),
      comment::binary-size(comment_length),
      rest::bitstring
    >> = bitstring

    [k, v] = String.split(comment, "=")
    comments = [[k, v] | comments]

    if length(comments) == total_comments do
      Enum.reverse(comments)
    else
      parse_comments(rest, comments, total_comments)
    end
  end
end
