defmodule VmsServer.Sheet.QueriesTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase
  import VmsServer.Factory

  alias VmsServer.Sheet.Queries

  describe "get_all_characteristics_by_race_id/1" do
    setup do
      race = insert(:race, name: "vampire")
      category = insert(:category_with_race, %{race_id: race.id})
      _characteristic = insert(:characteristics, %{category_id: category.id})
      _dynamic_characteristic = insert(:dynamic_characteristics, %{category_id: category.id})

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
      category = insert(:category_with_race, %{race_id: race.id})
      _characteristic = insert(:characteristics, %{category_id: category.id})
      _dynamic_characteristic = insert(:dynamic_characteristics, %{category_id: category.id})

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
  end
end
