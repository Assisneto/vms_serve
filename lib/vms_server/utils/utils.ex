defmodule VmsServer.Utils.Utils do
  alias VmsServer.Repo

  alias VmsServer.Sheet.{
    SubCategory,
    Category,
    Characteristics,
    DynamicCharacteristics
  }

  def get_struct_id_by_type(structs, type) do
    structs
    |> Enum.find(fn struct -> struct.type == type end)
    |> case do
      nil -> nil
      struct -> struct.id
    end
  end

  def insert_sub_categories(types) do
    Enum.map(types, &Repo.insert!(%SubCategory{type: &1}))
  end

  def insert_categories_and_characteristics(categories_set, characteristic_set, sub_categories) do
    Enum.each(categories_set, fn {sub_category_type, categories} ->
      sub_category_id = get_struct_id_by_type(sub_categories, sub_category_type)

      Enum.each(categories, fn category_or_tuple ->
        {category_type, race_id} =
          case category_or_tuple do
            {type, race_uuid} when is_atom(type) and is_binary(race_uuid) -> {type, race_uuid}
            type when is_atom(type) -> {type, nil}
          end

        if category_type in Category.type_enum() do
          category = insert_category(category_type, sub_category_id, race_id)

          insert_characteristics_for_category(
            characteristic_set,
            sub_category_type,
            category_type,
            category.id
          )
        end
      end)
    end)
  end

  defp insert_category(type, sub_category_id, race_id) do
    Repo.insert!(%Category{type: type, sub_category_id: sub_category_id, race_id: race_id})
  end

  defp insert_characteristics_for_category(
         characteristic_set,
         sub_category_type,
         category_type,
         category_id
       ) do
    characteristics =
      Map.get(
        Map.get(characteristic_set, sub_category_type, %{}),
        category_type,
        []
      )

    Enum.each(characteristics, fn characteristic ->
      case characteristic do
        {name, :dynamic} ->
          insert_dynamic_characteristic(category_id, Atom.to_string(name), "")

        name when is_atom(name) ->
          insert_static_characteristic(category_id, Atom.to_string(name), "")
      end
    end)
  end

  defp insert_static_characteristic(category_id, name, description) do
    Repo.insert!(%Characteristics{
      category_id: category_id,
      name: name,
      description: description
    })
  end

  defp insert_dynamic_characteristic(category_id, name, description) do
    Repo.insert!(%DynamicCharacteristics{
      category_id: category_id,
      name: name,
      description: description
    })
  end
end
