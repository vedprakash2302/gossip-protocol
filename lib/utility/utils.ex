defmodule Gossip.Utils do

  @moduledoc """
  This module defines the utility functions for the project.
  """
  def int_to_atom(n) do
    String.to_atom(Integer.to_string(n))
  end

  def first_enum(list) do
    List.first(Enum.take_random(list, 1))
  end

  def get_pid(n) do
    Process.whereis(int_to_atom(n))
  end

  def timeout do
    150
  end

  def get_task_pid(task) do
    elem(task, 1)
  end
end
