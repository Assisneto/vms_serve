defmodule VmsServer.Sheet.SubCategoriesTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.SubCategory

  describe "SubCategory changesets" do
    test "validates presence of required fields" do
      attrs = %{}
      changeset = SubCategory.changeset(%SubCategory{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).type
    end

    test "validates type is in enum" do
      invalid_attrs = %{type: :invalid_type}
      changeset = SubCategory.changeset(%SubCategory{}, invalid_attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).type

      Enum.each(VmsServer.Sheet.SubCategory.type_enum(), fn valid_type ->
        changeset =
          VmsServer.Sheet.SubCategory.changeset(%VmsServer.Sheet.SubCategory{}, %{
            type: valid_type
          })

        assert changeset.valid?
      end)
    end

    test "creates a sub_category with valid data" do
      attrs = %{type: :attributes}
      changeset = SubCategory.changeset(%SubCategory{}, attrs)
      assert changeset.valid?
      {:ok, sub_category} = Repo.insert(changeset)

      assert sub_category.type == attrs.type
    end
  end
end
