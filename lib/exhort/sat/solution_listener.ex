defmodule Exhort.SAT.SolutonListener do
  @moduledoc """
  Listen for responses from the model, calling `callback` for each solution.

  Solutions are transmitted in messages from a native module listener.

  The `callback` function must accept two arguments:
  1. A `SolverResponse` struct with the response received from the model
  2. An accumulator that may be used to accumulate response information from the
     callbacks. The accumulator is `nil` on the first callback and is then the
     result of the `callback` function for each subsequent response
  """

  use GenServer

  alias Exhort.SAT.SolverResponse

  def start_link(builder, callback) do
    GenServer.start_link(__MODULE__, {builder, callback})
  end

  @doc """
  Stop the server.
  """
  @spec stop(pid()) :: :ok
  def stop(pid) do
    GenServer.stop(pid)
  end

  @impl true
  def init({builder, callback}) do
    {:ok, {builder, callback, nil}}
  end

  @doc """
  Get the value of the accumulator held by the server, generated by the
  `callback` function.
  """
  def acc(pid) do
    GenServer.call(pid, :acc)
  end

  @impl true
  def handle_call(:acc, _from, {_builder, _callback, acc} = state) do
    {:reply, acc, state}
  end

  @doc """
  Handle a response from the model.
  """
  @impl true
  def handle_info(response, {builder, callback, acc}) do
    acc = callback.(SolverResponse.build(response, builder), acc)
    {:noreply, {builder, callback, acc}}
  end
end
