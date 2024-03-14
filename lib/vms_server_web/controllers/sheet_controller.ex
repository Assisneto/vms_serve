defmodule VmsServerWeb.SheetController do
  use VmsServerWeb, :controller

  action_fallback VmsServerWeb.FallbackController
  plug VmsServer.Plugs.AtomizeParams when action in [:create, :update]

  def get_characteristics_fields(conn, %{"race_id" => race_id}) do
    case VmsServer.Sheet.get_characteristics_fields(race_id) do
      [] -> handle_response([], conn, :characteristics_fields, :no_content)
      characteristics -> handle_response(characteristics, conn, :characteristics_fields, :ok)
    end
  end

  def create(%{assigns: %{atomized_params: params}} = conn, _params) do
    with {:ok, character} <- VmsServer.Sheet.create_character(params) do
      character
      |> handle_response(conn, :character_fields, :created)
    end
  end

  def update(%{assigns: %{atomized_params: %{id: character_id} = params}} = conn, _params) do
    with {:ok, character} <- VmsServer.Sheet.get_character_by_id(character_id),
         {:ok, _character_updated} <-
           VmsServer.Sheet.update_character(character, params) do
      handle_response(conn, :no_content)
    end
  end

  defp handle_response(response, conn, view, status),
    do:
      conn
      |> put_status(status)
      |> render(view, fields: response)

  defp handle_response(conn, status),
    do:
      conn
      |> resp(status, "")
      |> send_resp()
end
