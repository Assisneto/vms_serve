defmodule VmsServer.Plugs.AtomizeParams do
  @moduledoc """
  Plug que transforma as chaves dos parâmetros da requisição em átomos
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    conn.params
    |> Enum.reduce(%{}, &atomize_keys/2)
    |> then(&Plug.Conn.assign(conn, :atomized_params, &1))
  end

  def atomize_keys({key, value}, map) do
    Map.put(map, String.to_atom(key), value)
  rescue
    ArgumentError -> map
  end
end
