defmodule VmsServer.Sheet.CharacterTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.Character
  import VmsServer.Factory

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
      race = insert(:race)
      player = insert(:player)
      chronicle = insert(:chronicle)

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

    test "creates characteristics levels, and dynamic characteristics levels inside of character changeset" do
      race = insert(:race)
      player = insert(:player)
      chronicle = insert(:chronicle)
      characteristic = insert(:characteristics)
      dynamic_characteristic = insert(:dynamic_characteristics)

      attrs = %{
        name: "Aragorn",
        race_id: race.id,
        player_id: player.id,
        chronicle_id: chronicle.id,
        bashing: 5,
        lethal: 3,
        aggravated: 1,
        characteristics_levels: [
          %{
            characteristic_id: characteristic.id,
            level: 5
          }
        ],
        dynamic_characteristics_levels: [
          %{
            characteristic_id: dynamic_characteristic.id,
            level: 4,
            used: 2
          }
        ]
      }

      changeset = Character.create_changeset(%Character{}, attrs)
      assert changeset.valid?
      {:ok, character} = Repo.insert(changeset)

      assert length(character.characteristics_levels) == 1
      assert Enum.all?(character.characteristics_levels, fn cl -> cl.level == 5 end)
      assert length(character.dynamic_characteristics_levels) == 1

      assert Enum.all?(character.dynamic_characteristics_levels, fn dcl ->
               dcl.level == 4 and dcl.used == 2
             end)
    end

    test "updates a character's stats" do
      character = insert(:character, name: "Legolas", bashing: 0)

      updated_attrs = %{name: "Legolas Greenleaf", bashing: 2}
      changeset = Character.update_changeset(character, updated_attrs)
      {:ok, updated_character} = Repo.update(changeset)

      assert updated_character.name == updated_attrs.name
      assert updated_character.bashing == updated_attrs.bashing
    end

    test "updates a character with characteristics levels and dynamic characteristics levels" do
      race = insert(:race)
      player = insert(:player)
      chronicle = insert(:chronicle)
      characteristic = insert(:characteristics)
      dynamic_characteristic = insert(:dynamic_characteristics)

      initial_attrs = %{
        name: "Aragorn",
        race_id: race.id,
        player_id: player.id,
        chronicle_id: chronicle.id,
        bashing: 5,
        lethal: 3,
        aggravated: 1,
        characteristics_levels: [
          %{
            characteristic_id: characteristic.id,
            level: 5
          }
        ],
        dynamic_characteristics_levels: [
          %{
            characteristic_id: dynamic_characteristic.id,
            level: 4,
            used: 2
          }
        ]
      }

      {:ok, character} = Character.create_changeset(%Character{}, initial_attrs) |> Repo.insert()

      character =
        Repo.preload(character, [:characteristics_levels, :dynamic_characteristics_levels])

      updated_attrs = %{
        characteristics_levels: [
          %{
            # Mantém o ID original para clareza
            characteristic_id: characteristic.id,
            level: 6
          }
        ],
        dynamic_characteristics_levels: [
          %{
            # Mantém o ID original para clareza
            characteristic_id: dynamic_characteristic.id,
            level: 5,
            used: 3
          }
        ]
      }

      {:ok, updated_character} =
        character |> Character.update_changeset(updated_attrs) |> Repo.update()

      assert List.first(updated_character.characteristics_levels).level == 6

      assert List.first(updated_character.dynamic_characteristics_levels).level == 5 and
               List.first(updated_character.dynamic_characteristics_levels).used == 3
    end
  end
end
