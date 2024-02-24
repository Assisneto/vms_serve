defmodule VmsServer.Sheet.CharacteristicsLevel do
  use VmsServer.Schema
  import Ecto.Changeset
  alias VmsServer.Sheet.{Character, Characteristics}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "characteristics_level" do
    belongs_to :character, Character
    belongs_to :characteristic, Characteristics
    field :level, :integer

    timestamps()
  end

  @cast_fields [:character_id]
  @required_fields [:characteristic_id, :level]
  @spec changeset(CharacteristicsLevel.t(), %{
          :character_id => Ecto.UUID.t(),
          :characteristic_id => Ecto.UUID.t(),
          :level => integer()
        }) :: Ecto.Changeset.t()
  def changeset(characteristics_level \\ %__MODULE__{}, attrs) do
    characteristics_level
    |> cast(attrs, @required_fields ++ @cast_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:character_id)
    |> foreign_key_constraint(:characteristic_id)
    |> validate_number(:level, greater_than_or_equal_to: 0)
  end
end
