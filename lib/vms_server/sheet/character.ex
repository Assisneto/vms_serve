defmodule VmsServer.Sheet.Character do
  use VmsServer.Schema
  import Ecto.Changeset

  alias VmsServer.Sheet.{
    Player,
    Race,
    Chronicle,
    Characteristic,
    CharacteristicsLevel,
    DynamicCharacteristicsLevel
  }

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "character" do
    field :name, :string
    field :bashing, :integer
    field :lethal, :integer
    field :aggravated, :integer
    belongs_to :race, Race
    belongs_to :player, Player
    belongs_to :chronicle, Chronicle
    has_many :characteristics_levels, CharacteristicsLevel, on_replace: :delete_if_exists

    has_many :dynamic_characteristics_levels, DynamicCharacteristicsLevel,
      on_replace: :delete_if_exists

    timestamps()
  end

  @required_fields_create [:race_id, :name, :player_id, :chronicle_id]
  @optional_fields_create [:bashing, :lethal, :aggravated]
  @optional_fields_update [:name, :bashing, :lethal, :aggravated]

  @spec create_changeset(Character.t(), %{
          :race_id => Ecto.UUID.t(),
          :name => String.t(),
          :player_id => Ecto.UUID.t(),
          :chronicle_id => Ecto.UUID.t(),
          :characteristics_levels => [
            %{
              :characteristic_id => Ecto.UUID.t(),
              :level => integer()
            }
          ],
          :dynamic_characteristics_level => [
            %{
              :characteristic_id => Ecto.UUID.t(),
              :level => integer(),
              :used => integer()
            }
          ],
          optional(:bashing) => integer(),
          optional(:lethal) => integer(),
          optional(:aggravated) => integer()
        }) :: Ecto.Changeset.t()
  def create_changeset(character, attrs) do
    character
    |> cast(attrs, @required_fields_create ++ @optional_fields_create)
    |> validate_required(@required_fields_create)
    |> cast_assoc(:characteristics_levels, with: &CharacteristicsLevel.changeset/2)
    |> cast_assoc(:dynamic_characteristics_levels, with: &DynamicCharacteristicsLevel.changeset/2)
    |> foreign_key_constraint(:storyteller_id)
    |> foreign_key_constraint(:race_id)
    |> foreign_key_constraint(:player_id)
  end

  @spec update_changeset(Character.t(), %{
          optional(:name) => String.t(),
          optional(:bashing) => integer(),
          optional(:lethal) => integer(),
          optional(:aggravated) => integer(),
          optional(:characteristics_levels) => [
            %{
              :characteristic_id => Ecto.UUID.t(),
              :level => integer()
            }
          ],
          optional(:dynamic_characteristics_level) => [
            %{
              :characteristic_id => Ecto.UUID.t(),
              :level => integer(),
              :used => integer()
            }
          ]
        }) :: Ecto.Changeset.t()
  def update_changeset(character, attrs) do
    character
    |> cast(attrs, @optional_fields_update)
    |> cast_assoc(:characteristics_levels, with: &CharacteristicsLevel.changeset/2)
    |> cast_assoc(:dynamic_characteristics_levels, with: &DynamicCharacteristicsLevel.changeset/2)
  end
end
