defmodule VmsServer.Repo.Migrations.CreateSubCategoriesTable do
  use Ecto.Migration

  def change do
    create_query =
      "CREATE TYPE sub_categories_type AS ENUM ('attributes', 'abilities', 'benefits');"

    drop_query = "DROP TYPE IF EXISTS sub_categories_type"

    execute(create_query, drop_query)

    create table(:sub_categories, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :type, :sub_categories_type
    end
  end
end
