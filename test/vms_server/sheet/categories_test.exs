defmodule VmsServer.Sheet.CategoriesTest do
  use ExUnit.Case, async: true
  use VmsServer.DataCase

  alias VmsServer.Sheet.{Category}
  import VmsServer.Factory

  describe "Category changesets" do
    test "validates presence of required fields" do
      attrs = %{}
      changeset = Category.changeset(%Category{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).sub_category_id
      assert "can't be blank" in errors_on(changeset).type
    end

    test "validates type is in enum" do
      sub_category = insert(:sub_category)
      invalid_attrs = %{sub_category_id: sub_category.id, type: :invalid_type}
      changeset = Category.changeset(%Category{}, invalid_attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).type

      Enum.each(Category.type_enum(), fn valid_type ->
        changeset =
          Category.changeset(%Category{}, %{
            sub_category_id: sub_category.id,
            type: valid_type
          })

        assert changeset.valid?
      end)
    end

    test "creates a category with valid data" do
      sub_category = insert(:sub_category)
      attrs = %{sub_category_id: sub_category.id, type: :Physical}
      changeset = Category.changeset(%Category{}, attrs)
      assert changeset.valid?
      {:ok, category} = Repo.insert(changeset)

      assert category.type == attrs.type
    end
  end
end
