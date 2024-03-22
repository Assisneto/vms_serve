defmodule VmsServer.Sheet.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "user" do
    field :name, :string
    field :email, :string
    field :hashed_password, :string

    timestamps()
  end

  @spec changeset(
          User.t(),
          %{
            :name => String.t()
          }
        ) :: Ecto.Changeset.t()
  def changeset(user \\ %VmsServer.Sheet.User{}, attrs) do
    user
    |> cast(attrs, [:name, :email, :hashed_password])
    |> validate_required([:name])
  end
end
