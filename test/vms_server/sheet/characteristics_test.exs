defmodule VmsServer.Sheet.CharacteristicsTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.Characteristics
  import VmsServer.Factory

  describe "Characteristics changesets" do
    test "validates presence of required fields" do
      attrs = %{}
      changeset = Characteristics.create_changeset(%Characteristics{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).category_id
    end

    test "creates a characteristics with valid data" do
      category = insert(:category)

      attrs = %{
        name: "Speed",
        category_id: category.id,
        description: "Defines the character's speed"
      }

      changeset = Characteristics.create_changeset(%Characteristics{}, attrs)
      assert changeset.valid?
      {:ok, characteristics} = Repo.insert(changeset)

      assert characteristics.name == attrs.name
      assert characteristics.description == attrs.description
    end

    test "updates a characteristics's description" do
      characteristics = insert(:characteristics, description: "Initial description")

      updated_attrs = %{description: "Updated description"}
      changeset = Characteristics.update_changeset(characteristics, updated_attrs)
      {:ok, updated_characteristic} = Repo.update(changeset)

      assert updated_characteristic.description == updated_attrs.description
    end
  end
end
