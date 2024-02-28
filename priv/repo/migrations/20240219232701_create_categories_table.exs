defmodule VmsServer.Repo.Migrations.CreateCategoriesTable do
  use Ecto.Migration

  def change do
    create_query = """
    CREATE TYPE categories_type AS ENUM (
      'physical',
      'social',
      'mental',
      'talents',
      'skills',
      'knowledges',
      'flaws',
      'merits',
      'backgrounds',
      'virtues', -- vampire
      'disciplines', -- vampire
      'gifts', -- werewolf
      'renown', -- werewolf
      'spheres', -- mage
      'others'
    );
    """

    drop_query = "DROP TYPE IF EXISTS categories_type;"

    execute(create_query, drop_query)

    create table(:categories, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :sub_category_id, references(:sub_categories, type: :uuid), null: false
      add :type, :categories_type, null: false
    end
  end
end
