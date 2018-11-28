defmodule Gossip.RumorActor do

  @moduledoc """
  This module defines the individual rumor actor and its behaviour.
  """
  use GenServer

  @doc """
  This method starts the Genserver beneath our Rumor actor.
  """
  def start_link(node, peers) do
    GenServer.start_link(__MODULE__, [node, peers], name: Gossip.Utils.int_to_atom(node))
  end

  @doc """
  This method selects a random peer from the list of peers that are passed and sends the rumour.
  """
  def init_gossip(peers, message) do
    peer = Gossip.Utils.get_pid(Enum.random(peers))

    if peer != nil do
      send(peer, {:infect, message})
      send(peer, {:count, []})
    end

    init_gossip(peers, message)
  end

  @doc """
  This method perfirms initialization of our GenServer and starts listening for incoming rumors.
  """
  def init([node, peers]) do
    receive do
      {:infect, message} ->
        Task.start(fn -> init_gossip(peers, message) end)
        counter(1)
    end

    {:ok, node}
  end

  @doc """
  This method counts the number of times it has received a rumor. If the actor receives a rumor 10 times, it kills itself.
  """
  def counter(count) do
    if(count < 10) do
      receive do
        {:count, _} -> counter(count + 1)
      end
    else
      send(Process.whereis(:supervisor), {:converged, self()})
      Process.exit(self(), :normal)
    end
  end
end
