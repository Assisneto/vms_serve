defmodule VmsServer.Accounts do
  alias VmsServer.Accounts.User
  alias VmsServer.Repo

  @spec register_user(%{name: String.t(), password: String.t(), email: String.t()}) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(attr),
    do:
      attr
      |> User.changeset()
      |> Repo.insert()
end
