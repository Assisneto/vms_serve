defmodule VmsServerWeb.UserController do
  alias VmsServer.Accounts
  use VmsServerWeb, :controller
  action_fallback VmsServerWeb.FallbackController

  def create(conn, params) do
    with {:ok, user} <- Accounts.register_user(params) do
      user
      |> handle_response(conn, :user, :created)
    end
  end

  def login(conn, params) do
    with {:ok, user} <- Accounts.login(params) do
      user
      |> handle_response(conn, :user, :ok)
    end
  end

  defp handle_response(response, conn, view, status),
    do:
      conn
      |> put_status(status)
      |> render(view, fields: response)
end
