defmodule VmsServer.Sheet.QueriesTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase
  import VmsServer.Factory

  alias VmsServer.Sheet.Queries

  describe "get_all_characteristics_by_race_id/1" do
    setup do
      race = insert(:race, name: "vampire")
      category = insert(:category_with_race, %{race_id: race.id})

      insert(:characteristics, category_id: category.id, character_id: nil)
      insert(:dynamic_characteristics, category_id: category.id, character_id: nil)

      {:ok, race: race}
    end

    test "returns all characteristics for the given race id", %{race: race} do
      results = Queries.get_all_characteristics_by_race_id(race.id)

      assert length(results) > 0

      Enum.each(results, fn {category, _static_characteristics, _dynamic_characteristics} ->
        assert category.race_id == race.id or is_nil(category.race_id) or category.type == :others
      end)
    end

    test "returns an empty list when no characteristics are found for a race id" do
      race_id = "5f578e13-953b-43f8-ac25-7b921e3b6cab"

      results = Queries.get_all_characteristics_by_race_id(race_id)

      assert Enum.empty?(results)
    end
  end

  describe "get_category_by_race_id/1" do
    setup do
      race = insert(:race, name: "vampire")
      character = insert(:character, race_id: race.id)
      category = insert(:category_with_race, %{race_id: race.id})

      insert(:characteristics, category_id: category.id, character_id: nil)
      insert(:dynamic_characteristics, category_id: category.id, character_id: nil)

      insert(:characteristics, category_id: category.id, character_id: character.id)
      insert(:dynamic_characteristics, category_id: category.id, character_id: character.id)

      {:ok, race: race}
    end

    test "returns categories associated with the race id", %{race: race} do
      categories = Queries.get_category_by_race_id(race.id)

      assert length(categories) > 0

      Enum.each(categories, fn category ->
        assert category.race_id == race.id or is_nil(category.race_id) or category.type == :others
      end)
    end

    test "returns an empty list when no categories are found for a race id" do
      race_id = "5f578e13-953b-43f8-ac25-7b921e3b6cab"

      categories = Queries.get_category_by_race_id(race_id)

      assert Enum.empty?(categories)
    end

    test "excludes character-specific characteristics from the results", %{race: race} do
      results = Queries.get_all_characteristics_by_race_id(race.id)

      Enum.each(results, fn {_category, static_characteristics, dynamic_characteristics} ->
        Enum.each(static_characteristics ++ dynamic_characteristics, fn characteristic ->
          assert is_nil(characteristic.character_id)
        end)
      end)
    end
  end

  describe "get_character_by_id_group_by_category/1" do
    setup do
      race = insert(:race)
      character = insert(:character, race_id: race.id)
      category1 = insert(:category, type: :physical)
      category2 = insert(:category, type: :social)
      characteristic1 = insert(:characteristics, category_id: category1.id)
      characteristic2 = insert(:characteristics, category_id: category2.id)
      dynamic_characteristic1 = insert(:dynamic_characteristics, category_id: category1.id)
      dynamic_characteristic2 = insert(:dynamic_characteristics, category_id: category2.id)

      insert(:characteristics_level,
        character_id: character.id,
        characteristic_id: characteristic1.id
      )

      insert(:characteristics_level,
        character_id: character.id,
        characteristic_id: characteristic2.id
      )

      insert(:dynamic_characteristics_level,
        character_id: character.id,
        characteristic_id: dynamic_characteristic1.id
      )

      insert(:dynamic_characteristics_level,
        character_id: character.id,
        characteristic_id: dynamic_characteristic2.id
      )

      {:ok, character_id: character.id}
    end

    test "returns character data grouped by category", %{character_id: character_id} do
      result = Queries.get_character_by_id_group_by_category(character_id)

      assert {:ok, character} = result
      assert is_map(character)
      assert Map.has_key?(character, :characteristics)
      assert Map.has_key?(character, :dynamic_characteristics)

      assert character.characteristics
             |> Map.keys()
             |> Enum.any?(&(&1 == :physical || &1 == :social))
    end

    test "returns an error for a non-existent character", _context do
      non_existent_id = "00000000-0000-0000-0000-000000000000"

      result = Queries.get_character_by_id_group_by_category(non_existent_id)

      assert {:error, {:not_found, "Character not found"}} = result
    end
  end
end
