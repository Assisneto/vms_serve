defmodule VmsServer.Sheet.PlayerTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  import VmsServer.Factory

  alias VmsServer.Repo
  alias VmsServer.Sheet.Player

  describe "Player changesets" do
    test "creates a valid changeset" do
      player_data = build(:player)
      player = player_data |> Player.changeset(%{}) |> Repo.insert!()

      assert player.name == player_data.name
    end

    test "updates a player's name" do
      player = insert(:player, name: "Assis")

      updated_name = "Neto"

      changeset = Player.changeset(player, %{name: updated_name})
      {:ok, updated_player} = Repo.update(changeset)

      assert updated_player.name == updated_name
    end

    test "does not allow name to be nil" do
      changeset = Player.changeset(%Player{}, %{name: nil})

      refute changeset.valid?

      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
