defmodule VmsServer.Sheet.UserTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  import VmsServer.Factory

  alias VmsServer.Repo
  alias VmsServer.Sheet.User

  describe "User changesets" do
    test "creates a valid changeset" do
      user_data = build(:user)
      user = user_data |> User.changeset(%{}) |> Repo.insert!()

      assert user.name == user_data.name
    end

    test "updates a user's name" do
      user = insert(:user, name: "Assis")

      updated_name = "Neto"

      changeset = User.changeset(user, %{name: updated_name})
      {:ok, updated_user} = Repo.update(changeset)

      assert updated_user.name == updated_name
    end

    test "does not allow name to be nil" do
      changeset = User.changeset(%User{}, %{name: nil})

      refute changeset.valid?

      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
