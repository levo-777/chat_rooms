defmodule ServerWeb.RoomChannel do
  use ServerWeb, :channel

  alias Server.Rooms.{RoomServer, Room}
  alias Server.Rooms.Presence

  @impl true
  def join("room:lobby", _payload, socket) do
    user_id = socket.assigns.user_id

    {:ok, _} = Presence.track(self(), "room:lobby", user_id, %{})

    {:ok, raw_rooms} = RoomServer.list_rooms()

    rooms_payload =
      Enum.map(raw_rooms, fn %Room{room_id: room_id, room_name: room_name} ->
        presences = Presence.list("room:#{room_id}")
        %{
          room_id: room_id,
          room_name: room_name,
          user_count: map_size(presences)
        }
      end)

    {:ok, %{rooms: rooms_payload}, socket}
  end







  @impl true
  def handle_in("create-room", %{"room_name" => room_name}, socket) do

  end



end
