defmodule VmsServer.Repo.Migrations.CreateDynamicsCharacteristicsTable do
  use Ecto.Migration

  def change do
    create table(:dynamics_characteristics, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :category_id, references(:categories, type: :uuid), null: false
      add :race_id, references(:race, type: :uuid)
      timestamps()
    end
  end
end
