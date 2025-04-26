defmodule ServerWeb.RoomController do
  use ServerWeb, :controller

  alias Server.Rooms.RoomServer

  def show(conn, %{"room_id" => room_id}) do
    case RoomServer.get_room(room_id) do
      {:ok, _room} ->
        render(conn, :show, layout: false)
      {:error, :not_found} ->
        conn
        |> redirect(to: ~p"/")
    end
  end

end
