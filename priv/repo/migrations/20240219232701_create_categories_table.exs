defmodule VmsServer.Repo.Migrations.CreateCategoriesTable do
  use Ecto.Migration

  def change do
    create_query = """
    CREATE TYPE categories_type AS ENUM (
      'Physical',
      'Social',
      'Mental',
      'Talents',
      'Skills',
      'Knowledge',
      'Flaws',
      'Merits',
      'Backgrounds',
      'Virtues', -- vampire
      'Disciplines', -- vampire
      'Gifts', -- werewolf
      'Renown', -- werewolf
      'Spheres', -- mage
      'others'
    );
    """

    drop_query = "DROP TYPE IF EXISTS categories_type;"

    execute(create_query, drop_query)

    create table(:categories, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :category_type_id, references(:sub_categories, type: :uuid), null: false
      add :type, :categories_type
    end
  end
end
