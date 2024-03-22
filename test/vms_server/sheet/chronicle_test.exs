defmodule VmsServer.Sheet.ChronicleTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  import VmsServer.Factory

  alias VmsServer.Repo
  alias VmsServer.Sheet.Chronicle

  describe "Chronicle changesets" do
    test "creates a valid changeset with required fields" do
      attrs = %{
        title: "The Rise of Phoenix",
        description: "An epic tale of rebirth and renewal.",
        storyteller_id: insert(:user).id
      }

      changeset = Chronicle.create_changeset(attrs)

      assert changeset.valid?
    end

    test "requires title to be present" do
      attrs = %{description: "Missing title.", storyteller_id: insert(:user).id}
      changeset = Chronicle.create_changeset(%Chronicle{}, attrs)

      refute changeset.valid?
      assert %{title: ["can't be blank"]} == errors_on(changeset)
    end

    test "updates Chronicle's description" do
      chronicle =
        insert(:chronicle, title: "Original Title", description: "Original description.")

      updated_attrs = %{description: "Updated description."}
      changeset = Chronicle.update_changeset(chronicle, updated_attrs)

      {:ok, updated_chronicle} = Repo.update(changeset)
      assert updated_chronicle.description == "Updated description."
    end

    test "requires storyteller_id to be present" do
      attrs = %{title: "Lost Chronicles", description: "Tales of the unknown."}
      changeset = Chronicle.create_changeset(%Chronicle{}, attrs)

      refute changeset.valid?
      assert %{storyteller_id: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
