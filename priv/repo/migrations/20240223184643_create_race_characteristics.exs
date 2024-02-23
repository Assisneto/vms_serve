defmodule VmsServer.Repo.Migrations.CreateRaceCharacteristicsTable do
  use Ecto.Migration

  def change do
    create table(:race_characteristics, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :value, :text
      add :key, :text
      add :character_id, references(:character, type: :uuid), null: false
      timestamps()
    end
  end
end
