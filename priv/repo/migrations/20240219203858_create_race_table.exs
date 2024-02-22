defmodule VmsServer.Repo.Migrations.CreateRaceTable do
  use Ecto.Migration

  def change do
    create table(:race, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :description, :string
    end
  end
end
