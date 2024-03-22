defmodule VmsServer.SheetTest do
  use ExUnit.Case, async: true
  alias VmsServer.Sheet.{RaceCharacteristics, CharacteristicsLevel, DynamicCharacteristicsLevel}

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
      assert changeset.errors[:user_id] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:chronicle_id] == {"can't be blank", [validation: :required]}
    end

    test "creates a character with valid data" do
      race = insert(:race)
      user = insert(:user)
      chronicle = insert(:chronicle)

      attrs = %{
        name: "Aragorn",
        race_id: race.id,
        user_id: user.id,
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

    test "creates a character with characteristics levels, dynamic characteristics levels, race characteristics and character-specific characteristics" do
      race = insert(:race)
      user = insert(:user)
      chronicle = insert(:chronicle)
      characteristic = insert(:characteristics)
      dynamic_characteristic = insert(:dynamic_characteristics)
      race_characteristic_attrs = %{key: "Agility", value: "High"}
      category = insert(:category)

      attrs = %{
        name: "Legolas",
        race_id: race.id,
        user_id: user.id,
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
        race_characteristics: [race_characteristic_attrs],
        characteristics: [
          %{
            "category_id" => category.id,
            "name" => "Fortitude",
            "characteristics_levels" => %{
              "level" => 1
            }
          }
        ]
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
        user_id: "",
        chronicle_id: "",
        bashing: -1,
        lethal: -1,
        aggravated: -1
      }

      {:error, changeset} = Sheet.create_character(invalid_attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).race_id
      assert "can't be blank" in errors_on(changeset).user_id
      assert "can't be blank" in errors_on(changeset).chronicle_id
    end

    test "fails to create a character with non-existent race_id" do
      non_existent_uuid = "00000000-0000-0000-0000-000000000000"

      user = insert(:user)
      chronicle = insert(:chronicle)

      attrs = %{
        name: "Gandalf",
        race_id: non_existent_uuid,
        user_id: user.id,
        chronicle_id: chronicle.id,
        bashing: 0,
        lethal: 0,
        aggravated: 0
      }

      {:error, changeset} = Sheet.create_character(attrs)

      refute changeset.valid?
      assert "does not exist" in errors_on(changeset).race_id
    end

    test "fails to create a character with non-existent user_id" do
      non_existent_uuid = "00000000-0000-0000-0000-000000000000"
      race = insert(:race)
      chronicle = insert(:chronicle)

      attrs = %{
        name: "Gandalf",
        race_id: race.id,
        user_id: non_existent_uuid,
        chronicle_id: chronicle.id,
        bashing: 0,
        lethal: 0,
        aggravated: 0
      }

      {:error, changeset} = Sheet.create_character(attrs)

      refute changeset.valid?
      assert "does not exist" in errors_on(changeset).user_id
    end

    test "fails to create a character with non-existent chronicle_id" do
      non_existent_uuid = "00000000-0000-0000-0000-000000000000"
      race = insert(:race)
      user = insert(:user)

      attrs = %{
        name: "Gandalf",
        race_id: race.id,
        user_id: user.id,
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

  describe "create_user/1" do
    test "validates presence of required fields for user" do
      attrs = %{}
      {:error, changeset} = Sheet.create_user(attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "creates a user with valid data" do
      attrs = %{name: "Boromir", email: "boromir@bormir.com", hashed_password: "Asdasdqww12312"}
      {:ok, user} = Sheet.create_user(attrs)

      assert user.name == attrs.name
      assert user.email == attrs.email
      assert user.hashed_password == attrs.hashed_password
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
      storyteller = insert(:user)

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

  describe "get_characteristics_fields/1" do
    setup do
      race = insert(:race, name: "vampire")
      category = insert(:category_with_race, %{race_id: race.id})
      _characteristic = insert(:characteristics, %{category_id: category.id})
      _dynamic_characteristic = insert(:dynamic_characteristics, %{category_id: category.id})

      {:ok, race: race}
    end

    test "returns characteristics fields for the given race id", %{race: race} do
      results = Sheet.get_characteristics_fields(race.id)

      assert length(results) > 0

      Enum.each(results, fn {category, _static_characteristics, _dynamic_characteristics} ->
        assert category.race_id == race.id or is_nil(category.race_id) or category.type == :others
      end)
    end

    test "returns an empty list for an unknown race id", %{race: _race} do
      unknown_race_id = "00000000-0000-0000-0000-000000000000"

      results = Sheet.get_characteristics_fields(unknown_race_id)

      assert Enum.empty?(results)
    end
  end

  describe "update_character/2" do
    setup do
      race = insert(:race)
      user = insert(:user)
      chronicle = insert(:chronicle)

      character =
        insert(:character, race_id: race.id, user_id: user.id, chronicle_id: chronicle.id)

      {:ok, character: character}
    end

    test "updates a character with valid data", %{character: character} do
      updated_name = "Updated Name"
      attrs = %{name: updated_name}

      {:ok, updated_character} = Sheet.update_character(character, attrs)

      assert updated_character.name == updated_name
    end

    test "updates a character with dynamic characteristics levels", %{character: character} do
      dynamic_characteristic_level =
        insert(:dynamic_characteristics_level, character_id: character.id)

      updated_level = dynamic_characteristic_level.level + 1

      attrs = %{
        dynamic_characteristics_levels: [
          %{"id" => dynamic_characteristic_level.id, "level" => updated_level, "used" => 0}
        ]
      }

      {:ok, _updated_character} = Sheet.update_character(character, attrs)

      updated_dynamic_characteristic_level =
        Repo.get!(DynamicCharacteristicsLevel, dynamic_characteristic_level.id)

      assert updated_dynamic_characteristic_level.level == updated_level
    end

    test "updates a character with characteristics levels", %{character: character} do
      characteristic_level =
        insert(:characteristics_level, character_id: character.id)

      updated_level = characteristic_level.level + 1

      attrs = %{
        characteristics_levels: [
          %{"id" => characteristic_level.id, "level" => updated_level}
        ]
      }

      {:ok, _updated_character} = Sheet.update_character(character, attrs)

      updated_characteristics_level = Repo.get!(CharacteristicsLevel, characteristic_level.id)

      assert updated_characteristics_level.level == updated_level
    end

    test "updates a character with race characteristics", %{character: character} do
      race_characteristics =
        insert(:race_characteristics, character_id: character.id)

      updated_value = "Very Fast"

      attrs = %{
        race_characteristics: [
          %{"id" => race_characteristics.id, "key" => "Speed", "value" => updated_value}
        ]
      }

      {:ok, _updated_character} = Sheet.update_character(character, attrs)

      updated_race_characteristic = Repo.get!(RaceCharacteristics, race_characteristics.id)

      assert updated_race_characteristic.value == updated_value
    end
  end
end
