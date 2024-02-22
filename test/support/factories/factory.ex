defmodule VmsServer.Factory do
  use ExMachina.Ecto, repo: VmsServer.Repo

  def player_factory do
    %VmsServer.Sheet.Player{
      name: "Assis neto"
    }
  end

  def race_factory do
    %VmsServer.Sheet.Race{
      name: "Vampire",
      description: "Elegant and wise"
    }
  end
end
