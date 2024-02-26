defmodule VmsServer.SheetTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet
  alias VmsServer.Repo
  import VmsServer.Factory

  describe "create_character/1" do
    test "validates presence of required fields" do
      attrs = %{}
      {:error, changeset} = Sheet.create_character(attrs)

      refute changeset.valid?
      assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:race_id] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:player_id] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:chronicle_id] == {"can't be blank", [validation: :required]}
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

      {:ok, character} = Sheet.create_character(attrs)

      assert character.name == attrs[:name]
      assert character.bashing == attrs[:bashing]
      assert character.lethal == attrs[:lethal]
      assert character.aggravated == attrs[:aggravated]
    end

    test "creates a character with characteristics levels, dynamic characteristics levels, and race characteristics" do
      race = insert(:race)
      player = insert(:player)
      chronicle = insert(:chronicle)
      characteristic = insert(:characteristics)
      dynamic_characteristic = insert(:dynamic_characteristics)
      race_characteristic_attrs = %{key: "Agility", value: "High"}

      attrs = %{
        name: "Legolas",
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

      {:ok, character} = Sheet.create_character(attrs)

      character =
        Repo.preload(character, [
          :characteristics_levels,
          :dynamic_characteristics_levels,
          :race_characteristics
        ])

      assert length(character.characteristics_levels) == 1
      assert length(character.dynamic_characteristics_levels) == 1
      assert length(character.race_characteristics) == 1

      assert List.first(character.characteristics_levels).level == 5
      assert List.first(character.dynamic_characteristics_levels).level == 4
      assert List.first(character.dynamic_characteristics_levels).used == 2

      assert List.first(character.race_characteristics).key == "Agility"
      assert List.first(character.race_characteristics).value == "High"
    end

    test "fails to create a character with invalid data" do
      invalid_attrs = %{
        name: "",
        race_id: "",
        player_id: "",
        chronicle_id: "",
        bashing: -1,
        lethal: -1,
        aggravated: -1
      }

      {:error, changeset} = Sheet.create_character(invalid_attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).race_id
      assert "can't be blank" in errors_on(changeset).player_id
      assert "can't be blank" in errors_on(changeset).chronicle_id
    end

    test "fails to create a character with non-existent race_id" do
      non_existent_uuid = "00000000-0000-0000-0000-000000000000"

      player = insert(:player)
      chronicle = insert(:chronicle)

      attrs = %{
        name: "Gandalf",
        race_id: non_existent_uuid,
        player_id: player.id,
        chronicle_id: chronicle.id,
        bashing: 0,
        lethal: 0,
        aggravated: 0
      }

      {:error, changeset} = Sheet.create_character(attrs)

      refute changeset.valid?
      assert "does not exist" in errors_on(changeset).race_id
    end

    test "fails to create a character with non-existent player_id" do
      non_existent_uuid = "00000000-0000-0000-0000-000000000000"
      race = insert(:race)
      chronicle = insert(:chronicle)

      attrs = %{
        name: "Gandalf",
        race_id: race.id,
        player_id: non_existent_uuid,
        chronicle_id: chronicle.id,
        bashing: 0,
        lethal: 0,
        aggravated: 0
      }

      {:error, changeset} = Sheet.create_character(attrs)

      refute changeset.valid?
      assert "does not exist" in errors_on(changeset).player_id
    end

    test "fails to create a character with non-existent chronicle_id" do
      non_existent_uuid = "00000000-0000-0000-0000-000000000000"
      race = insert(:race)
      player = insert(:player)

      attrs = %{
        name: "Gandalf",
        race_id: race.id,
        player_id: player.id,
        chronicle_id: non_existent_uuid,
        bashing: 0,
        lethal: 0,
        aggravated: 0
      }

      {:error, changeset} = Sheet.create_character(attrs)

      refute changeset.valid?
      assert "does not exist" in errors_on(changeset).chronicle_id
    end
  end

  describe "create_player/1" do
    test "validates presence of required fields for player" do
      attrs = %{}
      {:error, changeset} = Sheet.create_player(attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "creates a player with valid data" do
      attrs = %{name: "Boromir"}
      {:ok, player} = Sheet.create_player(attrs)

      assert player.name == "Boromir"
    end
  end

  describe "create_chronicle/1" do
    test "validates presence of required fields for chronicle" do
      attrs = %{title: ""}
      {:error, changeset} = Sheet.create_chronicle(attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).title
    end

    test "creates a chronicle with valid data" do
      storyteller = insert(:player)

      attrs = %{
        title: "The Fall of Gondor",
        description: "A detailed account of the siege and battle.",
        storyteller_id: storyteller.id
      }

      {:ok, chronicle} = Sheet.create_chronicle(attrs)

      assert chronicle.title == "The Fall of Gondor"
      assert chronicle.description == "A detailed account of the siege and battle."
      assert chronicle.storyteller_id == storyteller.id
    end

    test "fails to create a chronicle with non-existent storyteller_id" do
      non_existent_uuid = "00000000-0000-0000-0000-000000000000"

      attrs = %{
        title: "The Rise of the Witch-king",
        description: "Exploration of Angmar's history.",
        storyteller_id: non_existent_uuid
      }

      {:error, changeset} = Sheet.create_chronicle(attrs)

      refute changeset.valid?
      assert "does not exist" in errors_on(changeset).storyteller_id
    end
  end
end
