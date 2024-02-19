defmodule VmsServer.Repo.Migrations.CreateCharacterTable do
  use Ecto.Migration

  def change do
    create table(:character, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :race_id, references(:race, type: :uuid), null: false
      add :name, :text
      add :player_id, references(:player, type: :uuid), null: false
      add :chronicle_id, references(:chronicle, type: :uuid), null: false
      add :bashing, :integer
      add :lethal, :integer
      add :aggravated, :integer
      timestamps()
    end
  end
end
