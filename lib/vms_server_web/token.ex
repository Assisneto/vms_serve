defmodule VmsServerWeb.Token do
  alias VmsServerWeb.Endpoint
  alias Phoenix.Token

  @sign_salt "put_this_in_envs"

  def sign(user), do: Token.sign(Endpoint, @sign_salt, %{user_id: user.id})
  def verify(token), do: Token.verify(Endpoint, @sign_salt, token)
end
