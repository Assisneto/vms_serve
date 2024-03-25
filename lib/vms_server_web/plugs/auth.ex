defmodule VmsServerWeb.Plugs.Auth do
  use VmsServerWeb, :controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case VmsServerWeb.Token.verify(token) do
          {:ok, data} ->
            assign(conn, :user_id, data)

          _error ->
            unauthorized_response(conn)
        end

      _ ->
        unauthorized_response(conn)
    end
  end

  defp unauthorized_response(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_view(VmsServerWeb.ErrorJSON)
    |> render(:error, %{error: :unauthorized})
    |> halt()
  end
end
