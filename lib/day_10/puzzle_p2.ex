defmodule Day10P2 do
  @moduledoc false
  import Enum

  def angle_between_points({x1, y1}, {x2, y2}, {x3, y3}) do
    a = :math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2)
    b = :math.pow(x2 - x3, 2) + :math.pow(y2 - y3, 2)
    c = :math.pow(x3 - x1, 2) + :math.pow(y3 - y1, 2)
    angle = Float.round(:math.acos((a + b - c) / :math.sqrt(4 * a * b)) * 180 / :math.pi(), 4)

    if x3 < 0 do
      angle * -1 + 360
    else
      angle
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
    Enum.flat_map(matrix, fn {line, y} ->
      line
      |> Enum.map(fn {sign, x} -> if sign == "#", do: {x, y} end)
      |> Enum.reject(&is_nil/1)
    end)
  end

  def centralize(matrix, point = {x, y}) do
    matrix
    |> Enum.reject(fn x -> x == point end)
    |> Enum.map(fn {px, py} -> {{px - x, -1 * py + y}, {px, py}} end)
  end

  def sort_and_remove_temp_points(points) do
    points
    |> Enum.sort_by(fn {{x, y}, _org_point} -> abs(x) + abs(y) end)
    |> Enum.map(fn {_point, org_point} -> org_point end)
  end

  def group_by_angles(points) do
    points
    |> Enum.map(fn {point, org_point} ->
      {angle_between_points({0, 1}, {0, 0}, point), point, org_point}
    end)
    |> Enum.group_by(fn {angle, _, _} -> angle end, fn {_, point, org_point} ->
      {point, org_point}
    end)
    |> Enum.sort()
    |> Enum.map(fn {_angle, points} -> sort_and_remove_temp_points(points) end)
  end

  def read_file(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.filter(fn x -> x != "" end)
  end

  def shoot(matrix) do
    shoot(matrix, [])
  end

  def shoot([], kills) do
    kills
  end

  def shoot(matrix, kills) do
    [[target | rest_line] | rest] = matrix
    kills = [target | kills]

    if empty?(rest_line) do
      shoot(rest, kills)
    else
      shoot(rest ++ [rest_line], kills)
    end
  end

  def run do
    matrix =
      read_file("files/day10.in.txt")
      |> generate_matrix
      |> parse_to_map
      |> centralize({20, 18})
      |> group_by_angles
      |> shoot
      |> Enum.reverse()

    # lines = matrix 
    # |> Enum.with_index() 
    # |> Enum.map(fn {{x,y}, i} -> "#{i}: #{x}, #{y}" end) 
    # |> Enum.join("\n")
    # IO.puts(lines)

    {x, y} = Enum.at(matrix, 199)
    x * 100 + y
  end
end

# input =  SpaceMapP2.read_file("files/day10.in.txt")
# matrix = input |> SpaceMapP2.generate_matrix |> SpaceMapP2.parse_to_map |> SpaceMapP2.centralize({20, 18}) |> SpaceMapP2.group_by_angles  |> SpaceMapP2.shoot |> Enum.reverse

# lines = Enum.with_index(matrix) |> Enum.map(fn {{x,y}, i} -> "#{i}: #{x}, #{y}" end) |> Enum.join("\n")
# IO.puts(lines)
# {x, y} = Enum.at(matrix, 199)
# IO.puts("answer: #{x*100 + y}")
