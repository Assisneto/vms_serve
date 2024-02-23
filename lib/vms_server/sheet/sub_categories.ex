defmodule VmsServer.Sheet.SubCategory do
  @moduledoc """
  The SubCategory schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type_enum [:attributes, :abilities, :benefits]

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "sub_categories" do
    field :type, Ecto.Enum, values: @type_enum
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          type: atom()
        }

  @required_fields [:type]

  @spec changeset(%__MODULE__{}, %{:type => atom()}) :: Ecto.Changeset.t()
  def changeset(sub_category \\ %VmsServer.Sheet.SubCategory{}, attrs) do
    sub_category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @type_enum)
  end

  def type_enum, do: @type_enum
end
