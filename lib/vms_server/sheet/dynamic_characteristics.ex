defmodule VmsServer.Sheet.DynamicCharacteristics do
  use VmsServer.Schema
  import Ecto.Changeset
  alias VmsServer.Sheet.Category

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "dynamics_characteristics" do
    field :name, :string
    field :description, :string
    belongs_to :category, Category

    timestamps()
  end

  @required_fields [:name, :category_id]
  @optional_fields [:description]

  @spec create_changeset(DynamicCharacteristic.t(), %{
          :name => String.t(),
          :category_id => Ecto.UUID.t(),
          optional(:description) => String.t()
        }) :: Ecto.Changeset.t()
  def create_changeset(dynamic_characteristic \\ %__MODULE__{}, attrs) do
    dynamic_characteristic
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:category_id)
  end

  @spec update_changeset(DynamicCharacteristic.t(), %{
          optional(:description) => String.t()
        }) :: Ecto.Changeset.t()
  def update_changeset(dynamic_characteristic, attrs) do
    dynamic_characteristic
    |> cast(attrs, @optional_fields)
  end
end
