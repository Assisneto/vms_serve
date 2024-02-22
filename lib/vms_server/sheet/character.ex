defmodule VmsServer.Sheet.Character do
  use VmsServer.Schema
  import Ecto.Changeset
  alias VmsServer.Sheet.{Player, Race, Chronicle}

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "character" do
    field :name, :string
    field :bashing, :integer
    field :lethal, :integer
    field :aggravated, :integer
    belongs_to :race, Race
    belongs_to :player, Player
    belongs_to :chronicle, Chronicle

    timestamps()
  end

  @required_fields_create [:race_id, :name, :player_id, :chronicle_id]
  @optional_fields_create [:bashing, :lethal, :aggravated]
  @optional_fields_update [:name, :bashing, :lethal, :aggravated]

  @spec create_changeset(Character.t(), %{
          :race_id => Ecto.UUID.t(),
          :name => String.t(),
          :player_id => Ecto.UUID.t(),
          :chronicle_id => Ecto.UUID.t(),
          optional(:bashing) => integer(),
          optional(:lethal) => integer(),
          optional(:aggravated) => integer()
        }) :: Ecto.Changeset.t()
  def create_changeset(character, attrs) do
    character
    |> cast(attrs, @required_fields_create ++ @optional_fields_create)
    |> validate_required(@required_fields_create)
    |> foreign_key_constraint(:storyteller_id)
  end

  @spec update_changeset(Character.t(), %{
          optional(:name) => String.t(),
          optional(:bashing) => integer(),
          optional(:lethal) => integer(),
          optional(:aggravated) => integer()
        }) :: Ecto.Changeset.t()
  def update_changeset(character, attrs) do
    character
    |> cast(attrs, @optional_fields_update)
  end
end
