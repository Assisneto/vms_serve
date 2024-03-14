defmodule VmsServerWeb.FallbackController do
  use VmsServerWeb, :controller

  def call(conn, {:error, {:not_found, message}}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: VmsServerWeb.ErrorJSON)
    |> render(:error, error: message)
  end

  def call(conn, {:error, changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: VmsServerWeb.ErrorJSON)
    |> render(:error, changeset: changeset)
  end
end
