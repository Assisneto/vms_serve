defmodule VmsServerWeb.SheetControllerTest do
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
end
