defmodule VmsServer.Sheet.DynamicCharacteristicsLevel do
  use VmsServer.Schema
  import Ecto.Changeset
  alias VmsServer.Sheet.{Character, DynamicCharacteristics}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "dynamics_characteristics_level" do
    belongs_to :character, Character
    belongs_to :dynamic_characteristic, DynamicCharacteristics, foreign_key: :characteristic_id
    field :level, :integer
    field :used, :integer

    timestamps()
  end

  @cast_fields [:character_id]
  @required_fields [:characteristic_id, :level, :used]

  @spec changeset(DynamicCharacteristicsLevel.t(), %{
          :character_id => Ecto.UUID.t(),
          :characteristic_id => Ecto.UUID.t(),
          :level => integer(),
          :used => integer()
        }) :: Ecto.Changeset.t()
  def changeset(dynamic_characteristic_level \\ %__MODULE__{}, attrs) do
    dynamic_characteristic_level
    |> cast(attrs, @required_fields ++ @cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:character_id)
    |> foreign_key_constraint(:characteristic_id)
    |> validate_number(:level, greater_than_or_equal_to: 0)
    |> validate_number(:used, greater_than_or_equal_to: 0)
  end

  def update_changeset(dynamic_characteristic_level, attrs) do
    dynamic_characteristic_level
    |> cast(attrs, [:level, :used])
    |> validate_required([:level, :used])
    |> validate_number(:level, greater_than_or_equal_to: 0)
    |> validate_number(:used, greater_than_or_equal_to: 0)
  end
end
