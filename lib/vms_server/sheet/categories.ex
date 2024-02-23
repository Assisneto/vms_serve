defmodule VmsServer.Sheet.Category do
  @moduledoc """
  The Category schema, representing various types of categories such as physical, social, mental, and specific ones like vampire disciplines, werewolf gifts, etc.
  """

  use VmsServer.Schema
  import Ecto.Changeset

  alias VmsServer.Sheet.SubCategory

  @type_enum [
    :Physical,
    :Social,
    :Mental,
    :Talents,
    :Skills,
    :Knowledge,
    :Flaws,
    :Merits,
    :Backgrounds,
    :Virtues,
    :Disciplines,
    :Gifts,
    :Renown,
    :Spheres,
    :others
  ]

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "categories" do
    belongs_to :sub_category, SubCategory

    field :type, Ecto.Enum, values: @type_enum
  end

  @required_fields [:sub_category_id, :type]

  @spec changeset(Category.t(), map()) :: Changeset.t()
  def changeset(category \\ %VmsServer.Sheet.Category{}, attrs) do
    category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @type_enum)
    |> assoc_constraint(:sub_category)
  end

  def type_enum, do: @type_enum
end
