defmodule VmsServer.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "user" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string

    timestamps()
  end

  @required_fields [:name, :email, :password]

  @spec changeset(
          User.t(),
          %{
            :name => String.t(),
            :email => String.t(),
            :password => String.t()
          }
        ) :: Ecto.Changeset.t()
  def changeset(user \\ %VmsServer.Accounts.User{}, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 3)
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> add_hashed_password()
  end

  defp add_hashed_password(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ),
       do: change(changeset, %{hashed_password: Argon2.hash_pwd_salt(password)})

  defp add_hashed_password(changeset), do: changeset
end
