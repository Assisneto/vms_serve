defmodule VmsServer.AccountsTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Accounts

  describe "create_user/1" do
    test "validates presence of required fields for user" do
      attrs = %{}
      {:error, changeset} = Accounts.register_user(attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "creates a user with valid data" do
      attrs = %{name: "Boromir", email: "boromir@bormir.com", password: "Asdasdqww12312"}
      {:ok, user} = Accounts.register_user(attrs)

      assert user.name == attrs.name
      assert user.email == attrs.email
      assert user.password == attrs.password
    end
  end
end
