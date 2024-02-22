defmodule VmsServer.Factory do
  use ExMachina.Ecto, repo: VmsServer.Repo

  def player_factory do
    %VmsServer.Sheet.Player{
      name: "Assis neto"
    }
  end
end
