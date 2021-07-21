defmodule GenReport do
  @moduledoc """
    This module provides a function to generate a report of worked hours per person, per month and per year
    in a company from multiple files in parallel
  """

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  @people [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  alias GenReport.Parser

  @doc """
    Builds a report of worked hours per person, per month and per year from multiple files in parallel

    ## Parameters
    - filenames: A list of CSV file names with the worked time data\n

    ## Examples
        iex> GenReport.build_from_many(["gen_report_1.csv", "gen_report_2.csv"])
        %{
          "all_hours" => %{...},
          "hours_per_month" => %{...},
          "hours_per_year" => %{...}
        }
  """
  @spec build_from_many(list) :: map
  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(fn filename -> build(filename) end)
    |> Enum.reduce(
      report_accumulator(),
      fn {:ok, result}, report ->
        merge_reports(result, report)
      end
    )
  end

  defp build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(
      report_accumulator(),
      fn person_data, report -> update_report_data(person_data, report) end
    )
  end

  defp merge_reports(
         %{
           "all_hours" => all_hours_a,
           "hours_per_month" => month_hours_a,
           "hours_per_year" => year_hours_a
         },
         %{
           "all_hours" => all_hours_b,
           "hours_per_month" => month_hours_b,
           "hours_per_year" => year_hours_b
         }
       ) do
    all_hours = merge_hours_data(all_hours_a, all_hours_b)

    month_hours = merge_nested_hours_data(month_hours_a, month_hours_b)

    year_hours = merge_nested_hours_data(year_hours_a, year_hours_b)


    %{
      "all_hours" => all_hours,
      "hours_per_month" => month_hours,
      "hours_per_year" => year_hours
    }
  end

  defp merge_nested_hours_data(data_a, data_b) do
    Stream.map(
      data_a,
      fn {name, person_hours_a} ->
        %{name => merge_hours_data(person_hours_a, Map.get(data_b, name))}
      end
    )
    |> Enum.reduce(
      %{},
      fn person_data, acc ->
        Map.put(
          acc,
          Map.keys(person_data) |> List.first(),
          Map.values(person_data) |> List.first()
        )
      end
    )
  end

  defp merge_hours_data(map_a, map_b) do
    Map.merge(map_a, map_b, fn _key, value_a, value_b -> value_a + value_b end)
  end

  defp update_report_data(
         [name, hours, _day, month, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => month_hours,
           "hours_per_year" => year_hours
         } = report
       ) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    person_month_hours = Map.put(month_hours[name], month, month_hours[name][month] + hours)

    person_year_hours = Map.put(year_hours[name], year, year_hours[name][year] + hours)

    %{
      report
      | "all_hours" => all_hours,
        "hours_per_month" => %{month_hours | name => person_month_hours},
        "hours_per_year" => %{year_hours | name => person_year_hours}
    }
  end

  defp report_accumulator do
    %{
      "all_hours" => generate_all_hours_map(),
      "hours_per_month" => generate_hours_per_month_map(),
      "hours_per_year" => generate_hours_per_year_map()
    }
  end

  defp generate_all_hours_map do
    @people
    |> Enum.into(%{}, fn elem -> {elem, 0} end)
  end

  defp generate_hours_per_month_map do
    @people
    |> Enum.into(%{}, fn elem -> {elem, create_month_hours()} end)
  end

  defp generate_hours_per_year_map do
    @people
    |> Enum.into(%{}, fn elem -> {elem, create_year_hours()} end)
  end

  defp create_year_hours do
    @years
    |> Enum.into(%{}, fn elem -> {elem, 0} end)
  end

  defp create_month_hours do
    @months
    |> Enum.into(%{}, fn elem -> {elem, 0} end)
  end
end
