defmodule VmsServerWeb.UserJSON do
  def user(%{fields: user}) do
    %{
      id: user.id,
      name: user.name
    }
  end
end
