defmodule VmsServerWeb.SheetJSON do
  def characteristics_fields(%{fields: categories}) do
    Enum.map(categories, fn {category, static_characteristics, dynamic_characteristics} ->
      render_category(category, static_characteristics, dynamic_characteristics)
    end)
  end

  defp render_category(category, static_characteristics, dynamic_characteristics) do
    %{
      id: category.id,
      type: category.type,
      static_characteristics: render_characteristics(static_characteristics),
      dynamic_characteristics: render_characteristics(dynamic_characteristics)
    }
  end

  defp render_characteristics(characteristics) do
    Enum.map(characteristics, fn characteristic ->
      %{
        id: characteristic.id,
        name: characteristic.name,
        description: characteristic.description,
        inserted_at: characteristic.inserted_at,
        updated_at: characteristic.updated_at
      }
    end)
  end
end
