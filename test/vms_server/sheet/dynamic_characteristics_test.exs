defmodule VmsServer.Sheet.DynamicCharacteristicsTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.DynamicCharacteristics
  alias VmsServer.Factory

  describe "DynamicCharacteristics changesets" do
    test "validates presence of required fields" do
      attrs = %{}
      changeset = DynamicCharacteristics.create_changeset(attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).category_id
    end

    test "creates a dynamic characteristic with valid data" do
      category = Factory.insert(:category)

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
    end

    test "updates a dynamic characteristic's description" do
      dynamic_characteristic =
        Factory.insert(:dynamic_characteristics,
          name: "Agility",
          description: "Initial description"
        )

      updated_attrs = %{description: "Updated agility description"}
      changeset = DynamicCharacteristics.update_changeset(dynamic_characteristic, updated_attrs)
      {:ok, updated_dynamic_characteristic} = Repo.update(changeset)

      assert updated_dynamic_characteristic.description == updated_attrs.description
    end
  end
end
