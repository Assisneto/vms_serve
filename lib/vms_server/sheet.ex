defmodule VmsServer.Sheet do
  alias VmsServer.Repo

  alias VmsServer.Sheet.{
    Player,
    Character,
    Chronicle
  }

  @spec create_player(%{name: String.t()}) :: {:ok, Player.t()} | {:error, Ecto.Changeset.t()}
  def create_player(attr),
    do:
      attr
      |> Player.changeset()
      |> Repo.insert()

  @spec create_chronicle(%{
          title: String.t(),
          description: String.t() | nil,
          storyteller_id: String.t()
        }) :: {:ok, Chronicle.t()} | {:error, Ecto.Changeset.t()}

  def create_chronicle(attrs),
    do:
      attrs
      |> Chronicle.create_changeset()
      |> Repo.insert()

  @spec create_character(%{
          :characteristics_levels => [%{characteristic_id: <<_::288>>, level: integer()}],
          :chronicle_id => <<_::288>>,
          :dynamic_characteristics_level => [
            %{characteristic_id: <<_::288>>, level: integer(), used: integer()}
          ],
          :name => binary(),
          :player_id => <<_::288>>,
          :race_characteristics => [%{key: binary(), value: binary()}],
          :race_id => <<_::288>>,
          optional(:aggravated) => integer(),
          optional(:bashing) => integer(),
          optional(:lethal) => integer()
        }) :: {:ok, Character.t()} | {:error, Ecto.Changeset.t()}
  def create_character(attrs) do
    Character.create_changeset(attrs)
    |> Repo.insert()
  end
end
