defmodule VmsServer.Sheet.Queries do
  import Ecto.Query, warn: false

  alias VmsServer.Repo

  alias VmsServer.Sheet.{
    Category,
    Characteristics,
    DynamicCharacteristics,
    Character,
    DynamicCharacteristicsLevel,
    CharacteristicsLevel,
    RaceCharacteristics
  }

  def get_all_characteristics_by_race_id(race_id) do
    categories = get_category_by_race_id(race_id)

    Enum.map(categories, fn category ->
      static_characteristics =
        Repo.all(
          from c in Characteristics,
            where: c.category_id == ^category.id and is_nil(c.character_id)
        )

      dynamic_characteristics =
        Repo.all(
          from d in DynamicCharacteristics,
            where: d.category_id == ^category.id and is_nil(d.character_id)
        )

      {category, static_characteristics, dynamic_characteristics}
    end)
  end

  def get_category_by_race_id(race_id) do
    categories_with_race_id =
      Category
      |> where([c], c.race_id == ^race_id)
      |> preload(:race)
      |> Repo.all()

    case categories_with_race_id do
      [] ->
        []

      _race_categories ->
        other_categories =
          Category
          |> where([c], c.type == :others or is_nil(c.race_id))
          |> preload(:race)
          |> Repo.all()

        other_categories ++ categories_with_race_id
    end
  end

  def get_character_by_id_group_by_category(id) do
    character = Repo.get(Character, id)

    case character do
      nil ->
        {:error, {:not_found, "Character not found"}}

      %Character{} = character ->
        characteristics_data =
          from(cl in CharacteristicsLevel,
            join: c in assoc(cl, :characteristic),
            join: cat in assoc(c, :category),
            where: cl.character_id == ^character.id,
            preload: [characteristic: {c, category: cat}]
          )
          |> Repo.all()
          |> Enum.group_by(& &1.characteristic.category.type)

        dynamic_characteristics_data =
          from(dcl in DynamicCharacteristicsLevel,
            join: dc in assoc(dcl, :dynamic_characteristic),
            join: cat in assoc(dc, :category),
            where: dcl.character_id == ^character.id,
            preload: [dynamic_characteristic: {dc, category: cat}]
          )
          |> Repo.all()
          |> Enum.group_by(& &1.dynamic_characteristic.category.type)

        race_characteristics_data =
          from(
            rc in RaceCharacteristics,
            where: rc.character_id == ^character.id
          )
          |> Repo.all()

        character_map = Map.from_struct(character)

        result =
          Map.merge(character_map, %{
            characteristics: characteristics_data,
            dynamic_characteristics: dynamic_characteristics_data,
            race_characteristics: race_characteristics_data
          })

        {:ok, result}
    end
  end
end
