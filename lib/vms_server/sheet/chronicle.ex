defmodule VmsServer.Sheet.Chronicle do
  use VmsServer.Schema
  import Ecto.Changeset
  alias VmsServer.Accounts.User

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "chronicle" do
    field :title, :string
    field :description, :string

    belongs_to :storyteller, User
    timestamps()
  end

  @fields_common [:title, :description]
  @fields_create @fields_common ++ [:storyteller_id]
  @fields_update @fields_common

  @spec create_changeset(Chronicle.t(), map()) :: Ecto.Changeset.t()
  def create_changeset(chronicle \\ %VmsServer.Sheet.Chronicle{}, attrs) do
    chronicle
    |> cast(attrs, @fields_create)
    |> validate_required(@fields_create)
    |> foreign_key_constraint(:storyteller_id)
  end

  @spec update_changeset(Chronicle.t(), map()) :: Ecto.Changeset.t()
  def update_changeset(chronicle, attrs) do
    chronicle
    |> cast(attrs, @fields_update)
    |> validate_required(@fields_update)
  end
end
