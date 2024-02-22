defmodule VmsServer.Repo.Migrations.CreateDynamicsCharacteristicsLevelTable do
  use Ecto.Migration

  def change do
    create table(:dynamics_characteristics_level, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :character_id, references(:character, type: :uuid), null: false
      add :characteristic_id, references(:dynamics_characteristics, type: :uuid), null: false
      add :level, :integer, null: false
      add :used, :integer, null: false
      timestamps()
    end

    create unique_index(:dynamics_characteristics_level, [:character_id, :characteristic_id])
  end
end
