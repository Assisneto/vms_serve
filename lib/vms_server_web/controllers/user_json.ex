defmodule VmsServerWeb.UserJSON do
  def user(%{fields: user}) do
    %{
      id: user.id,
      name: user.name
    }
  end

  def user_logged(%{fields: user}) do
    %{
      id: user.id,
      name: user.name,
      token: user.token
    }
  end
end
