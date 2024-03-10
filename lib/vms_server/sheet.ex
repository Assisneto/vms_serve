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
    character_specific_characteristics = Map.get(attrs, :character_specific_characteristics, [])
    character_changeset = Character.create_changeset(%Character{}, attrs)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:character, character_changeset)

    multi =
      Enum.reduce(character_specific_characteristics, multi, fn specific_char, acc_multi ->
        create_specific_characteristic_multi(acc_multi, specific_char)
      end)

    Repo.transaction(multi)
    |> handle_character_transaction_result()
  end

  defp create_specific_characteristic_multi(multi, %{
         "category_id" => category_id,
         "static_characteristics" => characteristics
       }) do
    Enum.reduce(characteristics, multi, fn %{"name" => name, "level" => level}, acc_multi ->
      characteristic_changeset =
        Characteristics.create_changeset(%{
          name: name,
          category_id: category_id
        })

      acc_multi
      |> Ecto.Multi.insert(
        {:characteristic, name},
        characteristic_changeset,
        fn %{character: character} -> %{character_id: character.id} end
      )
      |> Ecto.Multi.run(
        {:characteristic_level, name},
        fn %{character: character, characteristic: characteristic} ->
          characteristics_level_changeset =
            CharacteristicsLevel.changeset(%{
              characteristic_id: characteristic.id,
              level: level,
              character_id: character.id
            })

          case Repo.insert(characteristics_level_changeset) do
            {:ok, characteristic_level} -> {:ok, characteristic_level}
            {:error, changeset} -> {:error, changeset}
          end
        end
      )
    end)
  end

  defp handle_character_transaction_result({:ok, %{character: character}}) do
    {:ok, character}
  end

  defp handle_character_transaction_result({:error, _operation, error_value, _changes_so_far}) do
    {:error, error_value}
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
