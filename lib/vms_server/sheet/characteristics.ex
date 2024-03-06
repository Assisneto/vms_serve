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

  @required_fields [:name]
  @optional_fields [:name, :description, :character_id, :category_id]
  @update_fields [:name, :description]

  @spec create_changeset(Characteristics.t(), %{
          :name => String.t(),
          optional(:category_id) => Ecto.UUID.t(),
          optional(:description) => String.t(),
          optional(:character_id) => Ecto.UUID.t()
        }) :: Ecto.Changeset.t()
  def create_changeset(characteristics \\ %__MODULE__{}, attrs) do
    characteristics
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:character_id)
    |> validate_exclusive_fields([:character_id, :category_id])
    |> validate_presence_of_either([:character_id, :category_id])
  end

  @spec update_changeset(Characteristics.t(), %{
          optional(:name) => String.t(),
          optional(:description) => String.t()
        }) :: Ecto.Changeset.t()
  def update_changeset(characteristics, attrs) do
    characteristics
    |> cast(attrs, @update_fields)
  end

  defp validate_exclusive_fields(changeset, fields) do
    case Enum.map(fields, fn field -> Map.has_key?(changeset.changes, field) end) do
      [true, true] ->
        add_error(
          changeset,
          :base,
          "character_id and category_id cannot be present at the same time"
        )

      _ ->
        changeset
    end
  end

  defp validate_presence_of_either(changeset, fields) do
    field_values =
      Enum.map(fields, fn field ->
        Map.get(changeset.changes, field, Map.get(changeset.data, field))
      end)

    if Enum.all?(field_values, &is_nil/1) do
      add_error(
        changeset,
        :base,
        "Either #{Enum.join(fields, " or ")} must be present"
      )
    else
      changeset
    end
  end
end
