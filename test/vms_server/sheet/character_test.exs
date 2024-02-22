defmodule VmsServer.Sheet.CharacterTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.Character
  alias VmsServer.Factory

  describe "Character changesets" do
    test "validates presence of required fields" do
      attrs = %{}
      changeset = Character.create_changeset(%Character{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).race_id
      assert "can't be blank" in errors_on(changeset).player_id
      assert "can't be blank" in errors_on(changeset).chronicle_id
    end

    test "creates a character with valid data" do
      race = Factory.insert(:race)
      player = Factory.insert(:player)
      chronicle = Factory.insert(:chronicle)

      attrs = %{
        name: "Aragorn",
        race_id: race.id,
        player_id: player.id,
        chronicle_id: chronicle.id,
        bashing: 5,
        lethal: 3,
        aggravated: 1
      }

      changeset = Character.create_changeset(%Character{}, attrs)
      assert changeset.valid?
      {:ok, character} = Repo.insert(changeset)

      assert character.name == attrs.name
      assert character.bashing == attrs.bashing
      assert character.lethal == attrs.lethal
      assert character.aggravated == attrs.aggravated
    end

    test "updates a character's stats" do
      character = Factory.insert(:character, name: "Legolas", bashing: 0)

      updated_attrs = %{name: "Legolas Greenleaf", bashing: 2}
      changeset = Character.update_changeset(character, updated_attrs)
      {:ok, updated_character} = Repo.update(changeset)

      assert updated_character.name == updated_attrs.name
      assert updated_character.bashing == updated_attrs.bashing
    end
  end
end
