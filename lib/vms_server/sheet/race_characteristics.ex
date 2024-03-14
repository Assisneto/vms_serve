defmodule VmsServer.Sheet.RaceCharacteristics do
  use VmsServer.Schema
  import Ecto.Changeset
  alias VmsServer.Sheet.Character

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "race_characteristics" do
    field :value, :string
    field :key, :string
    belongs_to :character, Character

    timestamps()
  end

  @common_fields [:value, :character_id]
  @required_fields [:key]

  @spec changeset(RaceCharacteristics.t(), %{
          :value => String.t(),
          :key => String.t(),
          :character_id => Ecto.UUID.t()
        }) :: Ecto.Changeset.t()
  def changeset(race_characteristic \\ %__MODULE__{}, attrs) do
    race_characteristic
    |> cast(attrs, @required_fields ++ @common_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:character_id)
  end

  def update_changeset(race_characteristic, attrs) do
    race_characteristic
    |> cast(attrs, [:value, :key])
    |> validate_required([:value, :key])
  end
end
