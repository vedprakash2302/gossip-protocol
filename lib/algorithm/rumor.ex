defmodule Gossip.Rumor do

  @moduledoc """
  This module contains methods that set off the gossip algorithm and also defines a tracker to count the number of nodes that have converged.
  """
  require Logger

  @doc """
  This method initiates the gossip algorithm with the appropriate topology.
  """
  def init_rumor(selected_topology, num) do
    topology =
      case selected_topology do
        "full" ->
          Logger.info("Build full")
          Gossip.Topology.get_full(Enum.to_list(1..num))

        "3d_grid" ->
          Logger.info("Build 3d grid")
          Gossip.Topology.get_3d_grid(Enum.to_list(1..num))

        "line" ->
          Logger.info("Build line")
          Gossip.Topology.get_line(Enum.to_list(1..num))

        "imp_line" ->
          Logger.info("Build imperfect line")
          Gossip.Topology.random_line(Enum.to_list(1..num))

        "rand_2d" ->
          Logger.info("Build random 2d grid")
          Gossip.Topology.get_rand_2d_grid(Enum.to_list(1..num))

        "sphere" ->
          Logger.info("Build sphere")
          Gossip.Topology.get_sphere(Enum.to_list(1..num))

        true ->
          Logger.info("Selected topology not found")
          System.halt()
      end

    n = length(topology)

    # Spawn all the nodes in the topology.
    for i <- 1..n do
      peers = Enum.at(topology, i - 1)

      spawn(fn ->
        Gossip.RumorActor.start_link(i, peers)
      end)
    end

    #Initialize the tracker for determining the convergence of the topology.
    tracker = Task.async(fn -> tracker(n) end)

    #Register the tracker globally.
    Process.register(tracker.pid, :supervisor)
    start = System.monotonic_time(unquote(:milli_seconds))

    #Initiate the gossip.
    gossip_init(n)
    Task.await(tracker, n * 5000)
    time_spent = System.monotonic_time(unquote(:milli_seconds)) - start
    Logger.info("Execution time: #{time_spent}")
  end

  @doc """
  This method selects any one node in the topology randomly and infects it with the rumour.
  """
  def gossip_init(n) do
    init_node = Gossip.Utils.get_pid(Enum.random(1..n))

    if Process.alive?(init_node) do
      send(init_node, {:infect, "You've been infected."})
    end
  end

  @doc """
  This method listens to nodes that send a message after converging.
  It starts off with number of nodes in topology and reduces the counter on each node convergence.
  """
  def tracker(n) do
    cond do
      n > 0 ->
        receive do
          {:converged, pid} ->
            Logger.info("Process #{inspect(pid)} has converged, #{n - 1} more to go")
            tracker(n - 1)
        after
          3000 ->
            Logger.info("Node unable to converge. Skipping process.")
            tracker(n - 1)
        end

      true ->
        nil
    end
  end
end
