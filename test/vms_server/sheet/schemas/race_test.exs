defmodule VmsServer.Sheet.RaceTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  import VmsServer.Factory

  alias VmsServer.Repo
  alias VmsServer.Sheet.Race

  describe "Race changesets" do
    test "creates a valid changeset for Race" do
      race_attrs = %{name: "Mage", description: "Magika"}
      race = Race.changeset(%Race{}, race_attrs) |> Repo.insert!()

      assert race.name == race_attrs.name
      assert race.description == race_attrs.description
    end

    test "updates a Race's description" do
      race = insert(:race)

      updated_description = "changed"

      changeset = Race.changeset(race, %{description: updated_description})
      {:ok, updated_race} = Repo.update(changeset)

      assert updated_race.description == updated_description
    end

    test "name is required for Race" do
      attrs = %{}
      changeset = Race.changeset(%Race{}, attrs)

      assert changeset.valid? == false
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
