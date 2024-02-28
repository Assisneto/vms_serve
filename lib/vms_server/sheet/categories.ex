defmodule VmsServer.Sheet.Category do
  @moduledoc """
  The Category schema, representing various types of categories such as physical, social, mental, and specific ones like vampire disciplines, werewolf gifts, etc.
  """

  use VmsServer.Schema
  import Ecto.Changeset

  alias VmsServer.Sheet.{SubCategory, Race}

  @type_enum [
    :physical,
    :social,
    :mental,
    :talents,
    :skills,
    :knowledges,
    :flaws,
    :merits,
    :backgrounds,
    :virtues,
    :disciplines,
    :gifts,
    :renown,
    :spheres,
    :others
  ]

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "categories" do
    belongs_to :sub_category, SubCategory
    belongs_to :race, Race
    field :type, Ecto.Enum, values: @type_enum
  end

  @required_fields [:sub_category_id, :type]
  @optional_fields [:race_id]

  @spec changeset(Category.t(), map()) :: Changeset.t()
  def changeset(category \\ %VmsServer.Sheet.Category{}, attrs) do
    category
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @type_enum)
    |> assoc_constraint(:sub_category)
  end

  def type_enum, do: @type_enum
end
