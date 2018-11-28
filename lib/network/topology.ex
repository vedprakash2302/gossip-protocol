defmodule Gossip.Topology do

  @moduledoc """
  This module defines the topology that the gossip algorith uses to spread the rumor.
  We basically determine for every node the neighbours which it can infect with the rumour.
  """



  @doc """
  This method returns the list having neigbours for every node in a full network topology.
  Here, a node can infect any other node in the network.
  """
  def get_full(nodes_list) do
    Enum.map(nodes_list, fn node ->
      nodes = Enum.to_list(nodes_list)
      List.delete(nodes, node)
    end)
  end

  @doc """
  This method returns the list having neigbours for every node in a 3 dimensional network topology.
  """

  def get_3d_grid(nodes_list) do
    row = round(:math.pow(length(nodes_list), 1 / 3))

    nodes_location = gengrid(Enum.to_list(1..row), 3)

    distance_map =
      Enum.map(nodes_location, fn location ->
        x = Enum.at(location, 0)
        y = Enum.at(location, 1)
        z = Enum.at(location, 2)

        Enum.map(nodes_location, fn other_node ->
          a = :math.pow(x - Enum.at(other_node, 0), 2)
          b = :math.pow(y - Enum.at(other_node, 1), 2)
          c = :math.pow(z - Enum.at(other_node, 2), 2)
          :math.sqrt(a + b + c)
        end)
      end)

    Enum.map(distance_map, fn neighbours ->
      Enum.filter(1..length(neighbours), fn i -> Enum.at(neighbours, i - 1) == 1 end)
    end)
  end

  def gengrid(list), do: gengrid(list, length(list))

  def gengrid([], _), do: [[]]
  def gengrid(_, 0), do: [[]]

  def gengrid(list, i) do
    for x <- list, y <- gengrid(list, i - 1), do: [x | y]
  end

  @doc """
  This method returns the list having neigbours for every node in a 2 dimensional network topology.
  Here, a node can infect any other node in the network that is within a distance of 0.1 units.
  """

  def get_rand_2d_grid(nodes_list) do
    nodes_location = Enum.map(nodes_list, fn _ -> [:rand.uniform(), :rand.uniform()] end)

    distance_map =
      Enum.map(nodes_location, fn location ->
        x = Enum.at(location, 0)
        y = Enum.at(location, 1)

        Enum.map(nodes_location, fn other_node ->
          a = :math.pow(x - Enum.at(other_node, 0), 2)
          b = :math.pow(y - Enum.at(other_node, 1), 2)
          :math.sqrt(a + b)
        end)
      end)

    res =
      Enum.map(distance_map, fn neighbours ->
        Enum.filter(0..(length(neighbours) - 1), fn i ->
          Enum.at(neighbours, i) < 0.1 && Enum.at(neighbours, i) != 0
        end)
      end)

    Enum.map(res, fn peers ->
      if length(peers) == 0 do
        IO.puts("Multiple connected network created. Exiting.")
        System.halt()
      end
    end)

    res
  end

  @doc """
  This method returns the list having neigbours for every node in a line network topology.
  """

  def get_line(nodes_list) do
    Enum.map(nodes_list, fn x ->
      cond do
        x == 1 -> [x + 1]
        x == length(nodes_list) -> [x - 1]
        true -> [x + 1, x - 1]
      end
    end)
  end

  @doc """
  This method returns the list having neigbours for every node in a line network topology.
  Here, a node can infect it's immediate neighbour(s), and one other node selected at random.
  """

  def random_line(nodes_list) do
    Enum.map(nodes_list, fn x ->
      cond do
        x == 1 ->
          [x + 1, List.delete(nodes_list, x) |> List.delete(x + 1) |> Enum.random()]

        x == length(nodes_list) ->
          [x - 1, List.delete(nodes_list, x) |> List.delete(x - 1) |> Enum.random()]

        true ->
          [
            x + 1,
            x - 1,
            List.delete(nodes_list, x)
            |> List.delete(x + 1)
            |> List.delete(x - 1)
            |> Enum.random()
          ]
      end
    end)
  end

  @doc """
  This method returns the list having neigbours for every node in a sphere network topology.
  """

  def get_sphere(n) do
    row = round(:math.sqrt(length(n)))
    nodes = row * row

    Enum.map(1..nodes, fn x ->
      cond do
        x == 1 ->
          [x + 1, x + row, nodes - row + 1, row]

        x == row ->
          [x - 1, x + row, 1, nodes]

        x == nodes - row + 1 ->
          [x + 1, x - row, nodes, 1]

        x == nodes ->
          [x - 1, x - row, nodes - row + 1, row]

        x < row ->
          [x - 1, x + 1, x + row, nodes + x - row]

        x > nodes - row + 1 and x < nodes ->
          [x - 1, x + 1, x - row, rem(x + row, row)]

        rem(x - 1, row) == 0 ->
          [x + 1, x - row, x + row, x + row - 1]

        rem(x, row) == 0 ->
          [x - 1, x - row, x + row, x - row + 1]

        true ->
          [x - 1, x + 1, x - row, x + row]
      end
    end)
  end

  def check_2d_grid(nodes_list) do
    Enum.map(nodes_list, fn peer ->
      if length(peer) == 0 do
        IO.inspect("Multiple connected graphs detected")
        System.halt()
      end
    end)
  end
end
