defmodule VmsServer.Repo.Migrations.CreateCharacteristicsTable do
  use Ecto.Migration

  def change do
    create table(:characteristics, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :category_id, references(:categories, type: :uuid), null: false
      add :name, :string
      add :description, :text
      timestamps()
    end
  end
end
