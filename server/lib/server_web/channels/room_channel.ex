defmodule ServerWeb.RoomChannel do
  use ServerWeb, :channel

  alias Server.Rooms.{RoomServer, Room}
  alias Server.Rooms.Presence

  @impl true
  def join("room:lobby", _payload, socket) do
    user_id = socket.assigns.user_id

    {:ok, _} = Presence.track(self(), "room:lobby", user_id, %{})

    {:ok, raw_rooms} = RoomServer.list_rooms()

    rooms_payload = format_rooms(raw_rooms)

    {:ok, %{rooms: rooms_payload}, socket}
  end

  @impl true
  def handle_in("create-room", %{"room_name" => room_name}, socket) do
    room_id = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)

    case RoomServer.create_room(room_id, room_name) do
      {:ok, _new_room} ->
        broadcast!(socket, "rooms-update", %{rooms: payload_rooms()})
        push(socket, "redirect-ready", %{"room_id" => room_id})
        {:noreply, socket}

      {:error, :room_exists} ->
        push(socket, "error", %{"reason" => "room_exists"})
        {:noreply, socket}
    end
  end

  defp payload_rooms do
    {:ok, raw_rooms} = RoomServer.list_rooms()
    format_rooms(raw_rooms)
  end

  defp format_rooms(raw_rooms) do
    Enum.map(raw_rooms, fn %Room{room_id: id, room_name: name} ->
      presences = Presence.list("room:" <> id)
      %{room_id: id, room_name: name, user_count: map_size(presences)}
    end)
  end

end
