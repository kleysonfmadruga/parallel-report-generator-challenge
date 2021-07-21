defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @filenames ["gen_report_1.csv", "gen_report_2.csv", "gen_report_3.csv"]

  describe "build_from_many/1" do
    test "when a list of file names is given, generates the report" do
      response = GenReport.build_from_many(@filenames)

      expected_response = ReportFixture.build()

      assert expected_response == response
    end
  end

  describe "build_from_many/0" do
    test "when no file names are given, returns an error" do
      response = GenReport.build_from_many()

      expected_response = {:error, "Please provide a list of file names"}

      assert expected_response == response
    end
  end
end
