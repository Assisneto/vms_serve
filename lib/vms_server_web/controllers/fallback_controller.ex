defmodule VmsServerWeb.FallbackController do
  use VmsServerWeb, :controller

  def call(conn, {:error, {:not_found, message}}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: VmsServerWeb.ErrorJSON)
    |> render(:error, error: message)
  end

  def call(conn, {:error, changeset}) when is_struct(changeset, Ecto.Changeset) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: VmsServerWeb.ErrorJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(message)
    |> put_view(json: VmsServerWeb.ErrorJSON)
    |> render(:error, error: message)
  end
end
