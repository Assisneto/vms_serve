defmodule VmsServerWeb.UserControllerTest do
  use VmsServerWeb.ConnCase

  import VmsServer.Factory

  describe "POST /api/user (create)" do
    test "creates a user and returns 201 (Created)" do
      user_attrs = %{name: "Jane Doe", email: "jane@example.com", password: "Password123"}

      conn = post(conn(), "/api/user", user_attrs)

      response = json_response(conn, 201)
      assert response["id"]
      assert response["name"] == user_attrs.name
    end

    test "returns 400 (Bad Request) when creating a user with invalid data" do
      existing_user = insert(:user)
      user_attrs = %{name: "Jane Doe", email: existing_user.email, password: "Password123"}

      conn = post(conn(), "/api/user", user_attrs)
      assert json_response(conn, 400)["errors"]
    end
  end

  describe "POST /api/user/login (login)" do
    setup do
      hashed_password = Argon2.hash_pwd_salt("Password123")
      user = insert(:user, email: "user@example.com", hashed_password: hashed_password)
      %{user: user}
    end

    test "logs in and returns 200 (OK) with token", %{user: user} do
      login_attrs = %{email: user.email, password: "Password123"}

      conn = post(conn(), "/api/user/login", login_attrs)
      assert json_response(conn, 200)["token"]
    end

    test "returns 401 (Unauthorized) with wrong credentials", %{user: user} do
      login_attrs = %{email: user.email, password: "wrongpassword"}

      conn = post(conn(), "/api/user/login", login_attrs)
      assert json_response(conn, 401)["errors"]
    end

    test "returns 404 (Not found) when wrong email" do
      login_attrs = %{email: "not_found@not_fount.com", password: "Password123"}

      conn = post(conn(), "/api/user/login", login_attrs)
      assert json_response(conn, 404)["errors"]
    end
  end

  defp conn, do: build_conn() |> put_req_header("accept", "application/json")
end
