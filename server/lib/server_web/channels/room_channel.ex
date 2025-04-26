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
  def join("room:" <> room_id, _payload, socket) do
    user_id = socket.assigns.user_id
    username = socket.assigns.username
    topic = "room:" <> room_id

    case RoomServer.join_room(room_id, user_id, username) do
      {:ok, _room} ->
        {:ok, _} = Presence.track(self(), topic, room_id, %{user_id: user_id, username: username, room_id: room_id, joined_at: System.system_time(:second)})
        send(self(), :after_join)
        {:ok, assign(socket, :room_id, room_id)}
      {:error, :room_not_found} ->
        {:error, %{reason: "Room not found"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    room_id = socket.assigns.room_id

    RoomServer.add_message(room_id, "Server", "!", "#{socket.assigns.username}##{socket.assigns.user_id} joined")

    room_payload = payload_rooms(room_id)
    broadcast!(socket, "room-info", %{room: room_payload})
    {:noreply, socket}
  end

  @impl true
  def handle_in("leave-room", _payload, socket) do
    user_id = socket.assigns.user_id
    room_id = socket.assigns.room_id

    {:ok, _} = RoomServer.leave_room(room_id, user_id)
    case RoomServer.get_room(room_id) do
      {:ok, %Room{users: []}} -> RoomServer.delete_room(room_id)
      _ -> :ok
    end

    case RoomServer.get_room(room_id) do
      {:ok, _room} ->
        room_payload = payload_rooms(room_id)
        broadcast!(socket, "room-info", %{room: room_payload})
      _ -> :ok
    end

    RoomServer.add_message(room_id, "Server", "!", "#{socket.assigns.username}##{socket.assigns.user_id} left")
    ServerWeb.Endpoint.broadcast!("room:lobby", "rooms-update", %{rooms: payload_rooms()})
    {:reply, {:ok, %{}}, socket}
  end


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

  @impl true
  def handle_in("new-message",message, socket) when is_binary(message) do
    user_id = socket.assigns.user_id
    username = socket.assigns.username
    room_id = socket.assigns.room_id

    case RoomServer.add_message(room_id, username, user_id, message) do
      {:ok, _} ->
        room_payload = payload_rooms(room_id)
        broadcast!(socket, "room-info", %{room: room_payload})
        {:noreply, socket}
      nil ->
        {:error, :message_not_sent}
    end
    {:noreply, socket}
  end

  # @impl true
  # def terminate(_reason, socket) do
  #   if room_id = socket.assigns[:room_id] do
  #     user_id = socket.assigns.user_id

  #     {:ok, _} = RoomServer.leave_room(room_id, user_id)

  #     case RoomServer.get_room(room_id) do
  #       {:ok, %Room{users: []}} ->
  #         RoomServer.delete_room(room_id)
  #         {:noreply, socket}
  #       _ ->
  #         room_payload = payload_rooms(room_id)
  #         broadcast!(socket, "room-info", %{room: room_payload})
  #         {:noreply, socket}
  #     end
  #   end

  #   broadcast!(socket, "rooms-update", %{rooms: payload_rooms()})
  #   {:noreply, socket}
  # end

  defp payload_rooms do
    {:ok, raw_rooms} = RoomServer.list_rooms()
    format_rooms(raw_rooms)
  end

  defp payload_rooms(room_id) do
    case RoomServer.get_room(room_id) do
      {:ok, %Room{room_id: id, room_name: name, users: users, messages: messages}} ->
        %{
          room_id: id,
          room_name: name,
          user_count: length(users),
          messages: messages
        }
      _ -> nil
    end
  end

  def format_rooms(raw_rooms) do
    Enum.map(raw_rooms, fn %Room{ room_id: id, room_name: name, users: users } ->
      user_count = length(users)
      %{room_id: id, room_name: name, user_count: user_count}
    end)
  end

end
