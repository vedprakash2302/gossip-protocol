defmodule Gossip.PushSumActor do
  use GenServer

  @moduledoc """
  This module defines the individual actor node and its behaviours for Push Sum algorithm.
  """

  @doc """
  This method starts the underlying Genserver with appropriate arguments.
  """
  def start_link(node, peers) do
    GenServer.start_link(__MODULE__, [node, peers], name: Gossip.Utils.int_to_atom(node))
  end

  @doc """
  This method initializes the actor and listens for incoming messages from other nodes to initiate gossip.
  """
  def init([node, peers]) do
    receive do
      {:infect, s, w} ->
        task =
          Task.start(fn ->
            init_pushsum(node, peers)
          end)

        counter(3, s + node, w + 1, node, Gossip.Utils.get_task_pid(task))
    end

    {:ok, node}
  end

  @doc """
  This method selects a random peer and sends it a message.
  """
  def init_pushsum(node, peers) do
    {s, w} =
      receive do
        {:send, s_receive, w_receive} -> {s_receive, w_receive}
      end

    index = :rand.uniform(length(peers)) - 1
    peer = Gossip.Utils.get_pid(Enum.at(peers, index))

    if peer != nil do
      send(peer, {:infect, s, w})
    end

    init_pushsum(node, peers)
  end

  @doc """
  This method checks for convergence and computes the new values for s and w.
  """
  def counter(count, s, w, ratio, parent) do
    curr_ratio = s / w
    diff = abs(curr_ratio - ratio)
    count = check_tick(diff, count)

    if count < 1 do
      send(Process.whereis(:supervisor), {:converged, self()})
      Process.exit(self(), :normal)
    else
      s_half = s / 2
      w_half = w / 2
      send(parent, {:send, s_half, w_half})
      listener(count, s_half, w_half, curr_ratio, parent)
    end
  end

  @doc """
  This method listens to the incoming message and adds new s and w values to its own value.
  """
  def listener(count, s, w, curr_ratio, parent) do
    receive do
      {:infect, s_receive, w_receive} ->
        counter(count, s_receive + s, w_receive + w, curr_ratio, parent)
    after
      Gossip.Utils.timeout() -> counter(count, s, w, curr_ratio, parent)
    end
  end

  def check_tick(diff, curr_count) do
    cond do
      diff > :math.pow(10, -10) ->
        3

      true ->
        curr_count - 1
    end
  end
end
