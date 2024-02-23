defmodule VmsServer.Repo.Migrations.CreateCharacteristicsLevelTable do
  use Ecto.Migration

  def change do
    create table(:characteristics_level, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :character_id, references(:character, type: :uuid), null: false
      add :characteristic_id, references(:characteristics, type: :uuid), null: false
      add :level, :integer, null: false
      timestamps()
    end

    create unique_index(:characteristics_level, [:character_id, :characteristic_id])
  end
end
