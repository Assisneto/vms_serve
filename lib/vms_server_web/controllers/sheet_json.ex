defmodule VmsServerWeb.SheetJSON do
  def characteristics_fields(%{fields: categories}) do
    Enum.map(categories, fn {category, static_characteristics, dynamic_characteristics} ->
      render_category(category, static_characteristics, dynamic_characteristics)
    end)
  end

  def character_id(%{fields: character}) do
    %{
      id: character.id
    }
  end

  def character_fields_group_by_category(%{fields: character} = data) do
    character_map = character_fields(data)

    characteristics =
      Enum.map(character.characteristics, fn {category_type, characteristics} ->
        {category_type, Enum.map(characteristics, &render_characteristics_level/1)}
      end)

    dynamic_characteristics =
      Enum.map(character.dynamic_characteristics, fn {category_type, characteristics} ->
        {category_type, Enum.map(characteristics, &render_dynamic_characteristics_level/1)}
      end)

    race_characteristics =
      Enum.map(character.race_characteristics, &render_race_characteristics/1)

    Map.merge(character_map, %{
      characteristics: Map.new(characteristics),
      dynamic_characteristics: Map.new(dynamic_characteristics),
      race_characteristics: race_characteristics
    })
  end

  defp render_characteristics_level(cl) do
    %{
      id: cl.id,
      level: cl.level,
      characteristic_name: cl.characteristic.name,
      category_name: cl.characteristic.category.type,
      inserted_at: cl.inserted_at,
      updated_at: cl.updated_at
    }
  end

  defp render_dynamic_characteristics_level(dcl) do
    %{
      id: dcl.id,
      level: dcl.level,
      used: dcl.used,
      dynamic_characteristic_name: dcl.dynamic_characteristic.name,
      category_name: dcl.dynamic_characteristic.category.type,
      inserted_at: dcl.inserted_at,
      updated_at: dcl.updated_at
    }
  end

  def character_fields(%{fields: character}) do
    %{
      id: character.id,
      name: character.name,
      bashing: character.bashing,
      lethal: character.lethal,
      aggravated: character.aggravated,
      race_id: character.race_id,
      player_id: character.player_id,
      chronicle_id: character.chronicle_id,
      inserted_at: character.inserted_at,
      updated_at: character.updated_at
    }
  end

  defp render_race_characteristics(race_char) do
    %{
      id: race_char.id,
      key: race_char.key,
      value: race_char.value
    }
  end

  defp render_category(category, static_characteristics, dynamic_characteristics) do
    %{
      id: category.id,
      type: category.type,
      static_characteristics: render_characteristics(static_characteristics),
      dynamic_characteristics: render_characteristics(dynamic_characteristics)
    }
  end

  defp render_characteristics(characteristics) do
    Enum.map(characteristics, fn characteristic ->
      %{
        id: characteristic.id,
        name: characteristic.name,
        description: characteristic.description
      }
    end)
  end
end
