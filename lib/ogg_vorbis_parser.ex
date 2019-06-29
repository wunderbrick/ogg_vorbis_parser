defmodule OggVorbisParser do
  @moduledoc """
  A parser for VorbisComments in Ogg containers.

  While it's possible to use Vorbis streams without Ogg containers or with different kinds of containers,
  this parser expects Ogg. It might work for parsing the audio metadata in .ogv files, which are still Ogg containers
  with video streams and Vorbis streams, but this hasn't been tested much.

  The relevant part of an Ogg Vorbis file starts with an Ogg capture pattern (a file signature) followed by some Ogg container bits,
  the Vorbis identification header, and the Vorbis comment header.

  This package uses a recursive function to look for a comment header packet type of 3 immediately followed by the string "vorbis." This is the beginning of the comment header.
  """

  @doc """
  Parses VorbisComment if present.

  Note that the "format" comment in the example below says MP3 because this Ogg file from archive.org was probably converted from an mp3. The actual mp3 is included too as shown below.

  ## Examples

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

  """
  @spec parse(bitstring()) :: {:ok, map()} | {:error, :atom}
  def parse(filename) do
    case File.read(filename) do
      {:ok, bitstring} ->
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

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec find_comment_header(bitstring(), integer()) ::
          {:ok, map()} | {:error, :atom}
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

        {:ok,
         %{
           comments: parse_comments(rest, [], comment_list_length),
           vendor_string: vendor_string
         }}

      binary_size >= 500 ->
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
