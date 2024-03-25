defmodule VmsServer.Accounts do
  alias VmsServer.Accounts.User
  alias VmsServer.Repo

  @spec register_user(%{name: String.t(), password: String.t(), email: String.t()}) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(attrs),
    do:
      attrs
      |> User.changeset()
      |> Repo.insert()

  @spec login(map()) ::
          {:error, :unauthorize}
          | {:ok, User.t()}
  def login(%{"email" => email, "password" => password}) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, {:not_found, "User not found"}}
      user -> verify(user, password)
    end
  end

  defp verify(user, password) do
    case User.verify_password(user, password) do
      true -> {:ok, user}
      false -> {:error, :unauthorized}
    end
  end
end
