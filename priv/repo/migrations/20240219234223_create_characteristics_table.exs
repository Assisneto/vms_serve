defmodule VmsServer.Repo.Migrations.CreateCharacteristicsTable do
  use Ecto.Migration

  def change do
    create table(:characteristics, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :category_id, references(:categories, type: :uuid)
      add :character_id, references(:character, type: :uuid)
      add :name, :string, null: false
      add :description, :text
      timestamps()
    end
  end
end
