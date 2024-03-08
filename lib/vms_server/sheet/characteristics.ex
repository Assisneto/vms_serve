defmodule VmsServer.Sheet.Characteristics do
  use VmsServer.Schema
  import Ecto.Changeset

  alias VmsServer.Sheet.{Category, Character}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "characteristics" do
    field :name, :string
    field :description, :string
    belongs_to :category, Category
    belongs_to :character, Character
    timestamps()
  end

  @required_fields [:name, :category_id]
  @optional_fields [:name, :description, :character_id]
  @update_fields [:name, :description]

  @spec create_changeset(Characteristics.t(), %{
          :name => String.t(),
          :category_id => Ecto.UUID.t(),
          optional(:description) => String.t(),
          optional(:character_id) => Ecto.UUID.t()
        }) :: Ecto.Changeset.t()
  def create_changeset(characteristics \\ %__MODULE__{}, attrs) do
    characteristics
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:character_id)
  end

  @spec update_changeset(Characteristics.t(), %{
          optional(:name) => String.t(),
          optional(:description) => String.t()
        }) :: Ecto.Changeset.t()
  def update_changeset(characteristics, attrs) do
    characteristics
    |> cast(attrs, @update_fields)
  end
end
