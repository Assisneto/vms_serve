defmodule VmsServer.Utils.Utils do
  alias VmsServer.Repo

  alias VmsServer.Sheet.{
    SubCategory,
    Category,
    Characteristics,
    DynamicCharacteristics
  }

  @static_characteristic_ids %{
    "strength" => "9d6ec736-dadb-41a4-a5f8-a73e059a436c",
    "dexterity" => "fecfb864-a5f6-4e6c-920c-8945f782f03d",
    "stamina" => "3166d4c9-d9a6-41fb-a1fe-3853f2cb50e4",
    "charisma" => "bdf00a66-1b5e-499b-b1f4-0cbb732bdeaf",
    "manipulation" => "84e40531-130b-4b40-ad27-b0a0570b9916",
    "appearance" => "260efc5a-53ee-4026-950e-4f79751f6738",
    "perception" => "e1d1deb0-d2a1-492b-9ad0-62c33d68c8e4",
    "intelligence" => "8c7c02d8-3a4f-46d2-b6b9-40fe9d026e8c",
    "wits" => "246a37bd-c1ed-40f2-9c4b-bca7d6e5ef23",
    "alertness" => "4f310c80-852f-4833-96d6-33df1a35fbe2",
    "athletics" => "2c268df8-9360-4191-8361-8ad5a59e4864",
    "brawl" => "b6e8edba-0a84-4cf6-ad7c-72498b84030c",
    "dodge" => "6fa84831-3c80-4552-94a2-df130083e617",
    "empathy" => "649cc7cc-b243-4662-ba34-29f58997ddd4",
    "expression" => "51e23133-8649-4cad-8f0f-400634a0d92d",
    "intimidation" => "f718e89c-a1c6-4131-b9a0-4a43740fa8ef",
    "leadership" => "5f44119f-f0e6-43f2-8643-6c36d808e662",
    "streetwise" => "79cf06aa-beac-47a2-b771-fc37888dfae8",
    "subterfuge" => "165596d7-7888-482d-b6ec-5818a1b80345",
    "animal_ken" => "ff83b7bc-6f30-4786-82ff-f8d99d5d9872",
    "crafts" => "ae8a9097-639f-475e-a19f-5c782b2798ac",
    "drive" => "12664467-1d5a-416f-a747-c6900ebe4ce7",
    "etiquette" => "43e8ad7b-cc7e-41d3-bee6-0ba14f63a173",
    "firearms" => "70e64202-9075-4ca1-897a-3ff40e1cbcff",
    "melee" => "318a83dd-5b06-4339-9c01-ebed279cb779",
    "performance" => "83e6c542-4a2e-4bea-afae-ae27dc728002",
    "security" => "ee0f99e6-5f64-4312-81f9-acf9fdc97fd2",
    "stealth" => "9feb6769-ec0a-412d-8c00-8af766dbf9c0",
    "survival" => "c5779dc8-28df-4720-a4c9-9de88bd4cb6d",
    "academics" => "05239875-e360-45e8-9a31-2c2e6dc62677",
    "computer" => "058f29a2-6c1d-47fe-8480-219818c6b57f",
    "finance" => "a20d60a8-8125-4016-9088-ecc011b64b14",
    "investigation" => "0f23a176-9954-46b7-a184-d12eb87fe4f5",
    "law" => "c87df30a-12de-425b-8e97-12104c013d3e",
    "linguistics" => "ca31193f-3697-40b0-a751-be8f2cc930bc",
    "medicine" => "6366cacc-aab4-440f-a56b-0185eb08adbc",
    "occult" => "587909e5-5929-46c6-b070-bcc96f7ef5dc",
    "politics" => "35c2dcd7-c8bf-45b3-929d-bc7e93ea3184",
    "science" => "2f58b796-ac5b-4d35-afda-c7a629682b32"
  }

  @dynamic_characteristic_ids %{
    "willpower" => "9939a96c-ca18-4102-90ca-e71f3844ac70"
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
          id = Map.get(@dynamic_characteristic_ids, Atom.to_string(name), "")
          insert_dynamic_characteristic(category_id, Atom.to_string(name), "", id)

        name when is_atom(name) ->
          id = Map.get(@static_characteristic_ids, Atom.to_string(name), "")
          insert_static_characteristic(category_id, Atom.to_string(name), "", id)
      end
    end)
  end

  defp insert_static_characteristic(category_id, name, description, "") do
    Repo.insert!(%Characteristics{
      category_id: category_id,
      name: name,
      description: description
    })
  end

  defp insert_static_characteristic(category_id, name, description, id) do
    Repo.insert!(%Characteristics{
      id: id,
      category_id: category_id,
      name: name,
      description: description
    })
  end

  defp insert_dynamic_characteristic(category_id, name, description, "") do
    Repo.insert!(%DynamicCharacteristics{
      category_id: category_id,
      name: name,
      description: description
    })
  end

  defp insert_dynamic_characteristic(category_id, name, description, id) do
    Repo.insert!(%DynamicCharacteristics{
      id: id,
      category_id: category_id,
      name: name,
      description: description
    })
  end
end
