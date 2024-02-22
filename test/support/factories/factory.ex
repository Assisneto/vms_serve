defmodule VmsServer.Factory do
  alias VmsServer.Sheet.Player
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

  def chronicle_factory do
    %Player{id: storyteller_id} = insert(:player)

    %VmsServer.Sheet.Chronicle{
      title: "Rise and fall of noob saibot",
      description: "Demon noob saibot",
      storyteller_id: storyteller_id
    }
  end
end
