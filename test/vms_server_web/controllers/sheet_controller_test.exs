defmodule VmsServerWeb.SheetControllerTest do
  alias VmsServer.Repo
  use VmsServerWeb.ConnCase

  import VmsServer.Factory

  describe "get_characteristics_fields/2" do
    setup %{conn: conn} do
      race = insert(:race, name: "vampire")
      category = insert(:category_with_race, %{race_id: race.id})
      insert(:characteristics, %{category_id: category.id, name: "strength"})
      insert(:dynamic_characteristics, %{category_id: category.id, name: "willpower"})

      {:ok, %{conn: conn, race: race}}
    end

    test "returns 200 OK with characteristics fields for a known race id", %{
      conn: conn,
      race: race
    } do
      conn = get(conn, ~p"/api/sheet/characteristics/#{race.id}")
      assert json_response(conn, 200) != []
    end

    test "returns 204 No Content for an unknown race id", %{conn: conn} do
      unknown_race_id = "00000000-0000-0000-0000-000000000000"
      conn = get(conn, ~p"/api/sheet/characteristics/#{unknown_race_id}")
      assert response(conn, 204)
    end
  end

  describe "create/2" do
    setup %{conn: conn} do
      race = insert(:race, name: "vampire")
      player = insert(:player) |> IO.inspect(label: "Asdasd")
      chronicle = insert(:chronicle)
      category = insert(:category_with_race, %{race_id: race.id})

      characteristics =
        Enum.map(1..5, fn _ -> insert(:characteristics, %{category_id: category.id}) end)

      dynamic_characteristics =
        Enum.map(1..2, fn _ -> insert(:dynamic_characteristics, %{category_id: category.id}) end)

      characteristics_levels =
        Enum.map(characteristics, fn char ->
          %{characteristic_id: char.id, level: Enum.random(1..5)}
        end)

      dynamic_characteristics_levels =
        Enum.map(dynamic_characteristics, fn char ->
          %{characteristic_id: char.id, level: Enum.random(1..5), used: Enum.random(0..2)}
        end)

      attrs = %{
        name: "Benimary",
        race_id: race.id,
        player_id: player.id,
        chronicle_id: chronicle.id,
        characteristics_levels: characteristics_levels,
        dynamic_characteristics_levels: dynamic_characteristics_levels,
        character_specific_characteristics: [],
        race_characteristics: [%{key: "Agility", value: "High"}],
        bashing: 0,
        lethal: 0,
        aggravated: 0
      }

      {:ok, %{conn: conn, attrs: attrs}}
    end

    test "creates a character and returns 201 Created", %{conn: conn, attrs: attrs} do
      conn = post(conn, "/api/sheet", attrs)
      character_id = json_response(conn, 201)["id"]
      assert character_id != nil
      assert Repo.get_by(VmsServer.Sheet.Character, id: character_id) != nil
    end
  end
end
