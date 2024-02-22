defmodule VmsServer.Sheet.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "player" do
    field :name, :string

    timestamps()
  end

  @spec changeset(
          Player.t(),
          %{
            :name => String.t()
          }
        ) :: Ecto.Changeset.t()
  def changeset(player \\ %VmsServer.Sheet.Player{}, attrs) do
    player
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
