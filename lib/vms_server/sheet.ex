defmodule VmsServer.Sheet do
  alias VmsServer.Sheet.Queries
  alias VmsServer.Repo

  alias VmsServer.Sheet.{
    Player,
    Character,
    Chronicle,
    CharacteristicsLevel
  }

  @spec create_player(%{name: String.t()}) :: {:ok, Player.t()} | {:error, Ecto.Changeset.t()}
  def create_player(attr),
    do:
      attr
      |> Player.changeset()
      |> Repo.insert()

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
          :player_id => <<_::288>>,
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
          :player_id => binary(),
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

  def update_character(character, attrs) do
    with {:ok, character_updated} <-
           character |> Character.update_changeset(attrs) |> Repo.update() do
      insert_character_specific_characteristics_levels(character, attrs)
      {:ok, character_updated}
    end
  end

  def get_character_by_id(id) do
    case Repo.get(Character, id) do
      nil ->
        {:error, :not_found}

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

  defp insert_character_specific_characteristics_levels(_, _), do: :ok

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

      update_characteristics_levels(characteristics, matching_data)
    end)
  end

  defp update_characteristics_levels(characteristics, matching_data) do
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
