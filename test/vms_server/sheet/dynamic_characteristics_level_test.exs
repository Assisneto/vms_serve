defmodule VmsServer.Sheet.DynamicCharacteristicsLevelTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.DynamicCharacteristicsLevel
  import VmsServer.Factory

  describe "DynamicCharacteristicsLevel changesets" do
    test "validates presence of required fields" do
      attrs = %{}
      changeset = DynamicCharacteristicsLevel.changeset(%DynamicCharacteristicsLevel{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).characteristic_id
      assert "can't be blank" in errors_on(changeset).level
      assert "can't be blank" in errors_on(changeset).used
    end

    test "creates a dynamic characteristics level with valid data" do
      character = insert(:character)
      dynamic_characteristic = insert(:dynamic_characteristics)

      attrs = %{
        character_id: character.id,
        characteristic_id: dynamic_characteristic.id,
        level: 5,
        used: 3
      }

      changeset = DynamicCharacteristicsLevel.changeset(%DynamicCharacteristicsLevel{}, attrs)
      assert changeset.valid?
      {:ok, dynamic_characteristics_level} = Repo.insert(changeset)

      assert dynamic_characteristics_level.level == attrs.level
      assert dynamic_characteristics_level.used == attrs.used
    end
  end
end
