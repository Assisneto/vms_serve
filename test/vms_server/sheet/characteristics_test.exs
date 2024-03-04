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
    end

    test "updates a characteristics's description" do
      characteristics = insert(:characteristics, description: "Initial description")

      updated_attrs = %{description: "Updated description"}
      changeset = Characteristics.update_changeset(characteristics, updated_attrs)
      {:ok, updated_characteristic} = Repo.update(changeset)

      assert updated_characteristic.description == updated_attrs.description
    end

    test "creates a characteristics with character_id" do
      character = insert(:character)

      attrs = %{
        name: "Speed",
        character_id: character.id,
        description: "Defines the character's speed"
      }

      changeset = Characteristics.create_changeset(%Characteristics{}, attrs)
      assert changeset.valid?
      {:ok, characteristics} = Repo.insert(changeset)

      assert characteristics.name == attrs.name
      assert characteristics.description == attrs.description
      assert characteristics.character_id == attrs.character_id
    end

    test "creates a characteristics with category_id" do
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
      assert characteristics.category_id == attrs.category_id
    end
  end

  test "fails to create a characteristics with both category_id and character_id" do
    category = insert(:category)
    character = insert(:character)

    attrs = %{
      name: "Conflicting Attributes",
      category_id: category.id,
      character_id: character.id,
      description: "Should not be valid due to conflicting attributes"
    }

    changeset = Characteristics.create_changeset(%Characteristics{}, attrs)
    refute changeset.valid?

    assert "character_id and category_id cannot be present at the same time" in errors_on(
             changeset
           ).base
  end

  test "fails when neither category_id nor character_id is present" do
    attrs_without_both = %{
      name: "Intelligence",
      description: "Defines the character's intelligence"
    }

    changeset_without_both =
      Characteristics.create_changeset(%Characteristics{}, attrs_without_both)

    refute changeset_without_both.valid?

    assert "Either character_id or category_id must be present" in errors_on(
             changeset_without_both
           ).base
  end
end
