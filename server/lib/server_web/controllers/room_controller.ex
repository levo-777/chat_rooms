defmodule ServerWeb.RoomController do
  use ServerWeb, :controller

  alias Server.Rooms.RoomServer

  def room(conn, %{"room_id" => room_id}) do
    case RoomServer.get_room(room_id) do
      {:ok, _room} ->
        render(conn, :room, layout: false)
      {:error, :room_not_found} ->
        conn
        |> redirect(to: ~p"/")
    end
  end

end
