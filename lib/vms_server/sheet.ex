defmodule VmsServer.Sheet do
  alias VmsServer.Sheet.Queries
  alias VmsServer.Repo

  alias VmsServer.Sheet.{
    Player,
    Character,
    Chronicle,
    Characteristics,
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
          :characteristics_levels => [%{characteristic_id: binary(), level: integer()}],
          :chronicle_id => binary(),
          :dynamic_characteristics_level => [
            %{characteristic_id: binary(), level: integer(), used: integer()}
          ],
          :character_specific_characteristics => [
            %{
              category_id: binary(),
              static_characteristics: [%{level: integer(), name: binary()}]
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
    with {:ok, character} <- Character.create_changeset(%Character{}, attrs) |> Repo.insert() do
      Enum.each(attrs.character_specific_characteristics, fn specific_char ->
        create_specific_characteristic(character.id, specific_char)
      end)

      {:ok, character}
    end
  end

  defp create_specific_characteristic(character_id, %{
         "category_id" => category_id,
         "static_characteristics" => characteristics
       }) do
    Enum.each(characteristics, fn %{"name" => name, "level" => level} ->
      characteristic_changeset =
        Characteristics.create_changeset(%{
          name: name,
          character_id: character_id,
          category_id: category_id
        })

      case Repo.insert(characteristic_changeset) do
        {:ok, characteristic} ->
          characteristics_level_changeset =
            CharacteristicsLevel.changeset(%{
              characteristic_id: characteristic.id,
              level: level,
              character_id: character_id
            })

          Repo.insert(characteristics_level_changeset)

        {:error, changeset} ->
          {:error, changeset}
      end
    end)
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
