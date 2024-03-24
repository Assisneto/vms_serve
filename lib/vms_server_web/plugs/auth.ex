defmodule VmsServerWeb.Plugs.Auth do
  use VmsServerWeb, :controller

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- VmsServerWeb.Token.verify(token) do
      assign(conn, :user_id, data)
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: VmsServerWeb.ErrorJSON)
        |> render(:error, %{error: :unauthorized})
        |> halt()
    end
  end
end
