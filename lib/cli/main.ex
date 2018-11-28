defmodule Gossip.Main do

  @moduledoc """
  This modules defines the entry point of project. It parses argument and directs iput to the appropriate modules.
  """
  require Logger

  def main(args) do
    cond do
      length(args) == 3 ->
        algorithm = Enum.at(args, 2)

        # Redirecting depending on the type of algorithm.
        case algorithm do
          "gossip" ->
            Gossip.Rumor.init_rumor(
              Enum.at(args, 1),
              String.to_integer(Enum.at(args, 0))
            )

          "pushsum" ->
            Gossip.Pushsum.init_pushsum(
              Enum.at(args, 1),
              String.to_integer(Enum.at(args, 0))
            )
        end

      true ->
        Logger.info("Improper arguments")
    end
  end
end
