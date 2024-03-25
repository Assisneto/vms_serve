defmodule VmsServer.Sheet do
  alias VmsServer.Sheet.RaceCharacteristics
  alias VmsServer.Sheet.DynamicCharacteristicsLevel
  alias VmsServer.Sheet.Queries
  alias VmsServer.Repo

  alias VmsServer.Sheet.{
    Character,
    Chronicle,
    CharacteristicsLevel
  }

  @spec create_chronicle(%{
          title: String.t(),
          description: String.t() | nil,
          storyteller_id: String.t()
        }) :: {:ok, Chronicle.t()} | {:error, Ecto.Changeset.t()}

  def create_chronicle(attrs),
    do:
      attrs
      |> Chronicle.create_changeset()
      |> Repo.insert()

  @spec create_character(%{
          :characteristics_levels => [%{characteristic_id: <<_::288>>, level: integer()}],
          :chronicle_id => <<_::288>>,
          :dynamic_characteristics_level => [
            %{characteristic_id: <<_::288>>, level: integer(), used: integer()}
          ],
          :name => binary(),
          :user_id => <<_::288>>,
          :race_characteristics => [%{key: binary(), value: binary()}],
          :race_id => <<_::288>>,
          :characteristics => [
            %{
              category_id: <<_::288>>,
              name: binary(),
              characteristics_levels: %{
                level: binary()
              }
            }
          ],
          :name => binary(),
          :user_id => binary(),
          :race_characteristics => [%{key: binary(), value: binary()}],
          :race_id => binary(),
          optional(:aggravated) => integer(),
          optional(:bashing) => integer(),
          optional(:lethal) => integer()
        }) :: {:ok, Character.t()} | {:error, Ecto.Changeset.t()}
  def create_character(attrs) do
    with {:ok, character} <-
           attrs |> Character.create_changeset() |> Repo.insert() do
      insert_character_specific_characteristics_levels(character, attrs)
      {:ok, character}
    end
  end

  @spec update_character(
          Character.t(),
          %{
            optional(:aggravated) => integer(),
            optional(:bashing) => integer(),
            optional(:characteristics) => [
              %{category_id: <<_::288>>, characteristics_levels: map(), name: binary()}
            ],
            optional(:characteristics_levels) => [
              %{characteristic_id: <<_::288>>, level: integer()}
            ],
            optional(:dynamic_characteristics_level) => [
              %{characteristic_id: <<_::288>>, level: integer(), used: integer()}
            ],
            optional(:race_characteristics) => [
              %{id: <<_::288>>, key: binary(), value: binary()}
            ],
            optional(:lethal) => integer(),
            optional(:name) => binary()
          }
        ) :: any()
  def update_character(character, attrs) do
    with {:ok, character_updated} <-
           character
           |> Character.update_changeset(attrs)
           |> Repo.update(),
         {:ok, _} <- update_characteristics_levels(attrs),
         {:ok, _} <- update_dynamic_characteristics_levels(attrs),
         {:ok, _} <- update_race_characteristics(attrs),
         {:ok, _} <- insert_character_specific_characteristics_levels(character, attrs) do
      {:ok, character_updated}
    end
  end

  defp update_characteristics_levels(%{characteristics_levels: characteristics_levels}) do
    result =
      Enum.map(characteristics_levels, fn %{"id" => id, "level" => level} ->
        Repo.get!(CharacteristicsLevel, id)
        |> CharacteristicsLevel.update_changeset(%{level: level})
        |> Repo.update()
      end)

    {:ok, result}
  end

  defp update_characteristics_levels(_), do: {:ok, ""}

  defp update_race_characteristics(%{race_characteristics: race_characteristics}) do
    result =
      Enum.map(race_characteristics, fn %{"id" => id, "key" => key, "value" => value} ->
        Repo.get!(RaceCharacteristics, id)
        |> RaceCharacteristics.update_changeset(%{key: key, value: value})
        |> Repo.update()
      end)

    {:ok, result}
  end

  defp update_race_characteristics(_), do: {:ok, ""}

  defp update_dynamic_characteristics_levels(%{
         dynamic_characteristics_levels: dynamic_characteristics_levels
       }) do
    result =
      Enum.map(dynamic_characteristics_levels, fn %{"id" => id, "level" => level, "used" => used} ->
        Repo.get!(DynamicCharacteristicsLevel, id)
        |> DynamicCharacteristicsLevel.update_changeset(%{level: level, used: used})
        |> Repo.update()
      end)

    {:ok, result}
  end

  defp update_dynamic_characteristics_levels(_), do: {:ok, ""}

  @spec get_character_by_id(id :: <<_::288>>) ::
          {:ok, Character.t()}
          | {:error, {:not_found, String.t()}}
  def get_character_by_id(id) do
    case Repo.get(Character, id) do
      nil ->
        {:error, {:not_found, "Character not found"}}

      character ->
        sheet =
          character
          |> Repo.preload([
            :characteristics_levels,
            :dynamic_characteristics_levels,
            :race_characteristics
          ])

        {:ok, sheet}
    end
  end

  def get_character_by_id(id, {:group_by, :category}),
    do: Queries.get_character_by_id_group_by_category(id)

  defp insert_character_specific_characteristics_levels(%{characteristics: characteristics}, %{
         characteristics: characteristics_attr
       }) do
    result =
      update_characteristics_level_array(characteristics_attr, characteristics)
      |> Enum.map(fn %{"characteristics_levels" => characteristic_level} ->
        characteristic_level |> CharacteristicsLevel.changeset() |> Repo.insert()
      end)

    {:ok, result}
  end

  defp insert_character_specific_characteristics_levels(_, _), do: {:ok, ""}

  def update_characteristics_level_array(characteristics_with_level, characteristics_saved) do
    characteristics_map = build_characteristics_map(characteristics_saved)
    update_characteristics_with_map(characteristics_with_level, characteristics_map)
  end

  defp build_characteristics_map(characteristics_saved) do
    Enum.reduce(characteristics_saved, %{}, fn %VmsServer.Sheet.Characteristics{
                                                 name: name,
                                                 id: id,
                                                 character_id: character_id
                                               },
                                               acc ->
      Map.put(acc, name, %{id: id, character_id: character_id})
    end)
  end

  defp update_characteristics_with_map(characteristics_with_level, characteristics_map) do
    Enum.map(characteristics_with_level, fn characteristics ->
      characteristics_name = characteristics["name"]
      matching_data = Map.get(characteristics_map, characteristics_name, %{})

      update_characteristics_levels_map(characteristics, matching_data)
    end)
  end

  defp update_characteristics_levels_map(characteristics, matching_data) do
    characteristics_levels =
      characteristics["characteristics_levels"]
      |> Map.put("characteristic_id", matching_data[:id])
      |> Map.put("character_id", matching_data[:character_id])

    Map.put(characteristics, "characteristics_levels", characteristics_levels)
  end

  @type characteristic :: %{
          id: String.t(),
          name: String.t(),
          description: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @type category :: %{
          id: String.t(),
          type: String.t(),
          dynamic_characteristics: [characteristic],
          static_characteristics: [characteristic]
        }

  @spec get_characteristics_fields(race_id: Ecto.UUID.t()) :: [category] | []
  def get_characteristics_fields(race_id) do
    Queries.get_all_characteristics_by_race_id(race_id)
  end
end
