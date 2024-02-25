defmodule VmsServer.Sheet.RaceCharacteristicsTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.RaceCharacteristics
  import VmsServer.Factory

  describe "RaceCharacteristics changesets" do
    test "creates a valid changeset with required fields" do
      character = insert(:character)
      attrs = %{key: "Agility", value: "High", character_id: character.id}
      changeset = RaceCharacteristics.changeset(%RaceCharacteristics{}, attrs)
      {:ok, race_characteristics} = Repo.insert(changeset)

      assert race_characteristics.key == "Agility"
      assert race_characteristics.value == "High"
    end

    test "ensures key and character_id are required" do
      changeset = RaceCharacteristics.changeset(%RaceCharacteristics{}, %{value: "Medium"})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).key
    end
  end
end
