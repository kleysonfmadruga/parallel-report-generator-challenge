defmodule GenReport.ParserTest do
  use ExUnit.Case

  alias GenReport.Parser

  @filename "gen_report_1.csv"

  describe "parse_file/1" do
    test "when a file name is given, return the list of lines" do
      result =
        Parser.parse_file(@filename)
        |> Enum.member?(["daniele",7,29,"abril",2018])

      assert true == result
    end
  end
end
