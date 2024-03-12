defmodule VmsServer.Sheet.CharacterTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.Character
  import VmsServer.Factory

  describe "create_changeset/2" do
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

    test "creates a character with characteristics levels, dynamic characteristics levels, and race characteristics inside of character changeset" do
      race = insert(:race)
      player = insert(:player)
      chronicle = insert(:chronicle)
      characteristic = insert(:characteristics)
      dynamic_characteristic = insert(:dynamic_characteristics)
      race_characteristic_attrs = %{key: "Agility", value: "High"}

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
        ],
        race_characteristics: [race_characteristic_attrs]
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

      assert length(character.race_characteristics) == 1

      assert List.first(character.race_characteristics).key == "Agility"
      assert List.first(character.race_characteristics).value == "High"
    end

    test "updates a character's stats" do
      character = insert(:character, name: "Legolas", bashing: 0)

      updated_attrs = %{name: "Legolas Greenleaf", bashing: 2}
      changeset = Character.update_changeset(character, updated_attrs)
      {:ok, updated_character} = Repo.update(changeset)

      assert updated_character.name == updated_attrs.name
      assert updated_character.bashing == updated_attrs.bashing
    end

    test "updates a character with characteristics levels and dynamic characteristics levels and race characteristics" do
      race = insert(:race)
      player = insert(:player)
      chronicle = insert(:chronicle)
      characteristic = insert(:characteristics)
      dynamic_characteristic = insert(:dynamic_characteristics)
      race_characteristic_attrs = %{key: "generation", value: ""}

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
            level: 1
          }
        ],
        dynamic_characteristics_levels: [
          %{
            characteristic_id: dynamic_characteristic.id,
            level: 1,
            used: 1
          }
        ],
        race_characteristics: [race_characteristic_attrs]
      }

      {:ok, character} = Character.create_changeset(%Character{}, initial_attrs) |> Repo.insert()

      character =
        Repo.preload(character, [
          :characteristics_levels,
          :dynamic_characteristics_levels,
          :race_characteristics
        ])

      updated_attrs = %{
        characteristics_levels: [
          %{
            id: List.first(character.characteristics_levels).id,
            level: 6
          }
        ],
        dynamic_characteristics_levels: [
          %{
            id: List.first(character.dynamic_characteristics_levels).id,
            level: 5,
            used: 3
          }
        ],
        race_characteristics: [
          %{
            id: List.first(character.race_characteristics).id,
            value: "5"
          }
        ]
      }

      {:ok, updated_character} =
        character |> Character.update_changeset(updated_attrs) |> Repo.update()

      assert List.first(updated_character.characteristics_levels).level == 6

      assert List.first(updated_character.dynamic_characteristics_levels).level == 5 and
               List.first(updated_character.dynamic_characteristics_levels).used == 3

      assert List.first(updated_character.race_characteristics).value == "5" and
               List.first(updated_character.race_characteristics).key ==
                 race_characteristic_attrs.key
    end
  end

  describe "update_changeset/2" do
    test "updates a character with new lethal damage value" do
      character = insert(:character, name: "Gimli", lethal: 2)

      updated_attrs = %{lethal: 5}
      changeset = Character.update_changeset(character, updated_attrs)
      {:ok, updated_character} = Repo.update(changeset)

      assert updated_character.lethal == updated_attrs.lethal
    end

    test "update a character's characteristics levels" do
      character = insert(:character)
      characteristic_type = insert(:characteristics)

      existing_level =
        insert(:characteristics_level,
          character_id: character.id,
          characteristic_id: characteristic_type.id,
          level: 2
        )

      updated_level_attrs = %{
        id: existing_level.id,
        level: 5
      }

      update_attrs = %{characteristics_levels: [updated_level_attrs]}

      {:ok, updated_character} =
        character
        |> Repo.preload([
          :characteristics_levels
        ])
        |> Character.update_changeset(update_attrs)
        |> Repo.update()

      assert Repo.preload(updated_character, :characteristics_levels).characteristics_levels
             |> Enum.any?(fn characteristics_level -> characteristics_level.level == 5 end)
    end

    test "updates a character's dynamic characteristics levels" do
      character = insert(:character)
      dynamic_characteristic_type = insert(:dynamic_characteristics)

      existing_dynamic_level =
        insert(:dynamic_characteristics_level,
          character_id: character.id,
          characteristic_id: dynamic_characteristic_type.id,
          level: 2,
          used: 1
        )

      updated_dynamic_level_attrs = %{
        id: existing_dynamic_level.id,
        level: 4,
        used: 2
      }

      update_attrs = %{dynamic_characteristics_levels: [updated_dynamic_level_attrs]}

      {:ok, updated_character} =
        character
        |> Repo.preload([:dynamic_characteristics_levels])
        |> Character.update_changeset(update_attrs)
        |> Repo.update()

      assert Repo.preload(updated_character, :dynamic_characteristics_levels).dynamic_characteristics_levels
             |> Enum.any?(fn dynamic_level ->
               dynamic_level.level == 4 and dynamic_level.used == 2
             end)
    end

    test "updates a character's race characteristics" do
      character = insert(:character)

      race_characteristic =
        insert(:race_characteristics,
          character_id: character.id,
          key: "strength",
          value: "medium"
        )

      race_characteristics_attrs_update = [
        %{
          id: race_characteristic.id,
          key: "strength",
          value: "high"
        },
        %{
          key: "agility",
          value: "low"
        }
      ]

      update_attrs = %{race_characteristics: race_characteristics_attrs_update}

      {:ok, updated_character} =
        character
        |> Repo.preload([:race_characteristics])
        |> Character.update_changeset(update_attrs)
        |> Repo.update()

      updated_character = Repo.preload(updated_character, [:race_characteristics])

      assert Enum.any?(updated_character.race_characteristics, fn rc ->
               rc.key == "strength" and rc.value == "high" and rc.id == race_characteristic.id
             end)

      assert Enum.any?(updated_character.race_characteristics, fn rc ->
               rc.key == "agility" and rc.value == "low"
             end)
    end
  end
end
