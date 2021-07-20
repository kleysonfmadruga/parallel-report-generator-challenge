defmodule GenReport.Parser do
  @moduledoc """
    Provides a function to parse CSV report files
  """
  @doc """
    Parses CSV report files

    ## Parameters
    - filename: The CSV report file name:\n

    ## Examples
        iex> GenReport.Parser.parse_file("gen_report.csv")
        [[...], [...], [...], ...]
  """
  def parse_file(filename) do
    filename
    |> File.stream!()
    |> Stream.map(fn elem -> parse_line(elem) end)
  end

  defp parse_line(file) do
    file
    |> String.trim("\n")
    |> String.split(",")
    |> cast_numbers()
  end

  defp cast_numbers([name, worked_hours, day, month, year]) do
    [
      String.downcase(name),
      String.to_integer(worked_hours),
      String.to_integer(day),
      parse_month(month),
      String.to_integer(year)
    ]
  end

  defp parse_month(month) when month == "1", do: "janeiro"
  defp parse_month(month) when month == "2", do: "fevereiro"
  defp parse_month(month) when month == "3", do: "março"
  defp parse_month(month) when month == "4", do: "abril"
  defp parse_month(month) when month == "5", do: "maio"
  defp parse_month(month) when month == "6", do: "junho"
  defp parse_month(month) when month == "7", do: "julho"
  defp parse_month(month) when month == "8", do: "agosto"
  defp parse_month(month) when month == "9", do: "setembro"
  defp parse_month(month) when month == "10", do: "outubro"
  defp parse_month(month) when month == "11", do: "novembro"
  defp parse_month(month) when month == "12", do: "dezembro"
  defp parse_month(_month), do: "invalid month"
end
