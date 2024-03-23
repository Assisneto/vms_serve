defmodule VmsServer.Accounts.UserTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  import VmsServer.Factory

  alias VmsServer.Repo
  alias VmsServer.Accounts.User

  describe "User changesets" do
    test "creates a valid changeset" do
      user_data = build(:user)
      user = user_data |> User.changeset(%{}) |> Repo.insert!()

      assert user.name == user_data.name
    end

    test "does not allow name, email and hashed_password to be nil" do
      changeset = User.changeset(%User{}, %{name: nil})

      refute changeset.valid?

      assert ["can't be blank"] == errors_on(changeset).name
      assert ["can't be blank"] == errors_on(changeset).email
      assert ["can't be blank"] == errors_on(changeset).password
    end

    test "validates minimum length of name" do
      short_name = "Al"

      changeset =
        User.changeset(%User{}, %{
          name: short_name,
          email: "test@example.com",
          password: "Secret123"
        })

      refute changeset.valid?

      assert ["should be at least 3 character(s)"] == errors_on(changeset).name
    end

    test "validates minimum length of password" do
      short_password = "Short"

      changeset =
        User.changeset(%User{}, %{
          name: "Alice",
          email: "test@example.com",
          password: short_password
        })

      refute changeset.valid?

      assert ["should be at least 8 character(s)"] == errors_on(changeset).password
    end

    test "validates password must have at least one lower case character" do
      password_without_lowercase = "PASSWORD123"

      changeset =
        User.changeset(%User{}, %{
          name: "Alice",
          email: "test@example.com",
          password: password_without_lowercase
        })

      refute changeset.valid?

      assert ["at least one lower case character"] == errors_on(changeset).password
    end

    test "validates password must have at least one upper case character" do
      password_without_uppercase = "password123"

      changeset =
        User.changeset(%User{}, %{
          name: "Alice",
          email: "test@example.com",
          password: password_without_uppercase
        })

      refute changeset.valid?

      assert ["at least one upper case character"] == errors_on(changeset).password
    end

    test "validates email format" do
      invalid_email = "invalid-email.com"

      changeset =
        User.changeset(%User{}, %{name: "Alice", email: invalid_email, password: "Secret123"})

      refute changeset.valid?

      assert ["must have the @ sign and no spaces"] == errors_on(changeset).email
    end

    test "hashes password correctly when changeset is valid" do
      password = "Secret123!"
      user_params = %{name: "Alice", email: "alice@example.com", password: password}

      changeset = User.changeset(%User{}, user_params)

      assert changeset.valid?
      assert changeset.changes.hashed_password != nil
      assert changeset.changes.hashed_password != password
    end

    test "does not hash password when changeset is invalid" do
      invalid_user_params = %{name: "Al", email: "alice@example.com", password: "short"}

      changeset = User.changeset(%User{}, invalid_user_params)

      refute changeset.valid?

      assert Map.get(changeset.changes, :hashed_password) == nil
    end
  end
end
