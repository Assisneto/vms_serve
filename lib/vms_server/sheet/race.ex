defmodule VmsServer.Sheet.Race do
  @moduledoc """
  The Race schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          description: String.t()
        }

  @required_fields [:name]
  @optional_fields [:description]

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "race" do
    field :name, :string
    field :description, :string
  end

  @spec changeset(%{:name => String.t(), optional(:description) => binary()}) ::
          Ecto.Changeset.t()
  def changeset(race \\ %VmsServer.Sheet.Race{}, attrs) do
    race
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
