defmodule VmsServer.Sheet.Queries do
  import Ecto.Query, warn: false
  alias VmsServer.Repo
  alias VmsServer.Sheet.{Category, Characteristics, DynamicCharacteristics}

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
end
