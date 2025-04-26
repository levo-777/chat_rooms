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

  #@impl true
  #def join("room:" <> room_id, _payload, socket) do
    # user_id = socket.assigns.user_id
    # username = socket.assigns.username

    # case RoomServer.join_room(room_id, user_id, username) do
    #   {:ok, _room} ->
    #     send(self(), :after_join)
    #     {:ok, assign(socket, :room_id, room_id)}
    #   {:error, :room_not_found} ->
    #     {:error, %{reason: "Room not found"}}
    # end

  #end

  #@impl true
  #def handle_info(:after_join, socket) do
    # user_id = socket.assigns.user_id
    # username = socket.assigns.username
    # room_id = socket.assigns.room_id
    # topic = "room:" <> room_id

    # presences = Presence.list(topic)

    # unless Map.has_key?(presences, user_id) do
    #   broadcast!(socket, "user-joined", %{message: "#{username}##{user_id} joined"})
    # end

    # {:ok, _} = Presence.track(self(), "room:" <> room_id, user_id, %{username: username})

    # broadcast!(socket, "room:lobby", "rooms-update", %{rooms: payload_rooms()})
    # broadcast!(socket, "room:" <> room_id, "room-update", %{room: payload_room(room_id)})

    # {:noreply, socket}
  #end

  #@impl true
  #working template
  # def handle_in("create-room", %{"room_name" => room_name}, socket) do
  #   room_id = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)

  #   case RoomServer.create_room(room_id, room_name) do
  #     {:ok, _new_room} ->
  #       broadcast!(socket, "rooms-update", %{rooms: payload_rooms()})
  #       push(socket, "redirect-ready", %{"room_id" => room_id})
  #       {:noreply, socket}

  #     {:error, :room_exists} ->
  #       push(socket, "error", %{"reason" => "room_exists"})
  #       {:noreply, socket}
  #   end
  # end
@impl true
def handle_in("create-room", %{"room_name" => room_name}, socket) do
  user_id = socket.assigns.user_id
  username = socket.assigns.username
  room_id = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)

  case RoomServer.create_room(room_id, room_name) do
    {:ok, _new_room} ->
      case RoomServer.join_room(room_id, user_id, username) do
        {:ok, _room} ->
          broadcast!(socket, "rooms-update", %{rooms: payload_rooms()})
          push(socket, "redirect-ready", %{"room_id" => room_id})
          {:noreply, socket}
        {:error, :room_not_found} ->
          push(socket, "error", %{"reason" => "room_not_found"})
          {:noreply, socket}
      end
    {:error, :room_exists} ->
      push(socket, "error", %{"reason" => "room_exists"})
      {:noreply, socket}
  end
end


  defp payload_rooms do
    {:ok, raw_rooms} = RoomServer.list_rooms()
    format_rooms(raw_rooms)
  end

  defp payload_room_with_presence(room_id) do
    case RoomServer.get_room(room_id) do
      {:ok, %Room{room_id: id, room_name: name}} ->
        presences = Presence.list("room:" <> id)
        %{room_id: id, room_name: name, user_count: map_size(presences)}
      _ -> nil
    end
  end


  def format_rooms(raw_rooms) do
    Enum.map(raw_rooms, fn %Room{ room_id: id, room_name: name, users: users } ->
      user_count = length(users)
      %{room_id: id, room_name: name, user_count: user_count}
    end)
  end

  defp format_rooms_with_presence(raw_rooms) do
    Enum.map(raw_rooms, fn %Room{room_id: id, room_name: name} ->
      presences = Presence.list("room:" <> id)
      %{room_id: id, room_name: name, user_count: map_size(presences)}
    end)
  end

  #simple templates
  # defp format_rooms(raw_rooms) do
  #   Enum.map(raw_rooms, fn %Room{room_id: id, room_name: name, users: users} ->
  #     # Use the length of the users list from the Room struct for user count
  #     user_count = length(users)
  #     %{room_id: id, room_name: name, user_count: user_count}
  #   end)
  # end

  # defp payload_room(room_id) do
  #   case RoomServer.get_room(room_id) do
  #     {:ok, %Room{room_id: id, room_name: name, users: users}} ->
  #       user_count = length(users)  # Get user count directly from the users list
  #       %{room_id: id, room_name: name, user_count: user_count}
  #     _ -> nil
  #   end
  # end


end
