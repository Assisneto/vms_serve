defmodule VmsServer.Sheet.DynamicCharacteristicsTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.DynamicCharacteristics
  import VmsServer.Factory

  describe "DynamicCharacteristics changesets" do
    test "validates presence of required fields" do
      attrs = %{}
      changeset = DynamicCharacteristics.create_changeset(attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "creates a dynamic characteristic with valid data" do
      category = insert(:category)

      attrs = %{
        name: "Agility",
        category_id: category.id,
        description: "Defines the character's agility"
      }

      changeset = DynamicCharacteristics.create_changeset(%DynamicCharacteristics{}, attrs)
      assert changeset.valid?
      {:ok, dynamic_characteristic} = Repo.insert(changeset)

      assert dynamic_characteristic.name == attrs.name
      assert dynamic_characteristic.description == attrs.description
      assert dynamic_characteristic.category_id == attrs.category_id
    end

    test "updates a dynamic characteristic's description" do
      dynamic_characteristic =
        insert(:dynamic_characteristics,
          name: "Agility",
          description: "Initial description"
        )

      updated_attrs = %{description: "Updated agility description"}
      changeset = DynamicCharacteristics.update_changeset(dynamic_characteristic, updated_attrs)
      {:ok, updated_dynamic_characteristic} = Repo.update(changeset)

      assert updated_dynamic_characteristic.description == updated_attrs.description
    end

    test "creates a dynamic characteristics with category_id and character_id" do
      character = insert(:character)
      category = insert(:category)

      attrs = %{
        name: "Agility",
        character_id: character.id,
        category_id: category.id,
        description: "Defines the character's agility"
      }

      changeset = DynamicCharacteristics.create_changeset(%DynamicCharacteristics{}, attrs)
      assert changeset.valid?
      {:ok, dynamic_characteristic} = Repo.insert(changeset)

      assert dynamic_characteristic.name == attrs.name
      assert dynamic_characteristic.description == attrs.description
      assert dynamic_characteristic.character_id == attrs.character_id
      assert dynamic_characteristic.category_id == attrs.category_id
    end
  end

  test "fails to create dynamic characteristic without category_id" do
    attrs = %{
      name: "Incomplete",
      description: "Missing category_id"
    }

    changeset = DynamicCharacteristics.create_changeset(%DynamicCharacteristics{}, attrs)
    refute changeset.valid?
    assert "can't be blank" in errors_on(changeset).category_id
  end

  test "creates dynamic characteristic with only category_id" do
    category = insert(:category)

    attrs = %{
      name: "Category Only",
      category_id: category.id,
      description: "Only category_id is present"
    }

    changeset = DynamicCharacteristics.create_changeset(%DynamicCharacteristics{}, attrs)
    assert changeset.valid?
    {:ok, dynamic_characteristic} = Repo.insert(changeset)

    assert dynamic_characteristic.category_id == attrs.category_id
    assert dynamic_characteristic.character_id == nil
  end
end
