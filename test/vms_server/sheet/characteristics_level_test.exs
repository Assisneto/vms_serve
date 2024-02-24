defmodule VmsServer.Sheet.CharacteristicsLevelTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.CharacteristicsLevel
  import VmsServer.Factory

  describe "CharacteristicsLevel changesets" do
    test "validates presence of required fields" do
      attrs = %{}
      changeset = CharacteristicsLevel.changeset(%CharacteristicsLevel{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).characteristic_id
      assert "can't be blank" in errors_on(changeset).level
    end

    test "creates a CharacteristicsLevel with valid data" do
      character = insert(:character)
      characteristic = insert(:characteristics)

      attrs = %{
        character_id: character.id,
        characteristic_id: characteristic.id,
        level: 5
      }

      changeset = CharacteristicsLevel.changeset(%CharacteristicsLevel{}, attrs)
      assert changeset.valid?
      {:ok, characteristics_level} = Repo.insert(changeset)

      assert characteristics_level.level == attrs.level
    end

    test "validates level is greater than or equal to 0" do
      character = insert(:character)
      characteristic = insert(:characteristics)

      invalid_attrs = %{
        character_id: character.id,
        characteristic_id: characteristic.id,
        level: -1
      }

      changeset = CharacteristicsLevel.changeset(%CharacteristicsLevel{}, invalid_attrs)
      refute changeset.valid?
      assert "must be greater than or equal to 0" in errors_on(changeset).level
    end
  end
end
