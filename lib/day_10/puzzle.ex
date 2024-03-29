defmodule Day10 do
  @moduledoc false
  import Map

  def line_formula({x1, y1}, {x2, y2}, x) do
    m =
      if x2 == x1 do
        1
      else
        y2 - y1 / x2 - x1
      end

    b = y1 - m * x1
    m * x + b
  end

  def on_line({x1, y1}, {x2, y2}, {cx, cy}) do
    dxc = cx - x1
    dyc = cy - y1
    dxl = x2 - x1
    dyl = y2 - y1

    on_line = dxc * dyl - dyc * dxl == 0

    on_line &&
      if abs(dxl) >= abs(dyl) do
        Enum.member?(x1..x2, cx)
      else
        Enum.member?(y1..y2, cy)
      end
  end

  def generate_matrix(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, "")
      |> Enum.filter(fn x -> x != "" end)
    end)
    |> Enum.map(&Enum.with_index/1)
    |> Enum.with_index()
  end

  def parse_to_map(matrix) do
    matrix
    |> Enum.reduce(%{}, fn {line, y}, map ->
      Enum.reduce(line, map, fn {sign, x}, map ->
        if sign == "#", do: put(map, {x, y}, {x, y}), else: map
      end)
    end)
  end

  def add_cords(matrix) do
    matrix
    |> Enum.map(fn {line, y} ->
      Enum.map(line, fn {sign, x} -> "#{x},#{y}:#{sign}" end) |> Enum.join("|")
    end)
  end

  def read_file(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.filter(fn x -> x != "" end)
  end

  def check_line(map, start_point, end_point) do
    {start_point, rest} = pop(map, start_point)
    {end_point, rest} = pop(rest, end_point)

    Map.values(rest)
    |> Enum.reduce(true, fn point, acc ->
      acc && !on_line(start_point, end_point, point)
    end)
  end

  def check_points(matrix) do
    Map.values(matrix)
    |> Enum.map(fn start_point ->
      {start_point,
       Enum.reduce(Map.values(matrix), 0, fn end_point, acc ->
         if start_point != end_point && check_line(matrix, start_point, end_point) do
           acc + 1
         else
           acc
         end
       end)}
    end)
  end

  def get_best(points) do
    points
    |> Enum.max_by(fn {_point, value} -> value end)
  end

  def run do
    read_file("lib/day_10/input.txt")
    |> generate_matrix
    |> parse_to_map
    |> check_points
    |> get_best
  end
end
