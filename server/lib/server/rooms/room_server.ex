defmodule Server.Rooms.RoomServer do
  use GenServer

  alias Server.Rooms.{Room, RoomTable}

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %RoomTable{}, name: __MODULE__)
  end

  def create_room(room_id, room_name) do
    GenServer.call(__MODULE__, {:create_room, room_id, room_name})
  end

  def list_rooms do
    GenServer.call(__MODULE__, :list_rooms)
  end

  def join_room(room_id, user_id, username) do
    GenServer.call(__MODULE__, {:join_room, room_id, user_id, username})
  end

  def get_room(room_id) do
    GenServer.call(__MODULE__, {:get_room, room_id})
  end

  def user_in_room?(room_id, user_id) do
    GenServer.call(__MODULE__,{:user_in_room?, room_id, user_id})
  end

  def leave_room(room_id, user_id) do
    GenServer.call(__MODULE__,{:leave_room, room_id, user_id})
  end

  def add_message(room_id, from, from_id, msg) do
    GenServer.call(__MODULE__, {:add_message, room_id, from, from_id, msg})
  end

  def delete_room(room_id) do
    GenServer.call(__MODULE__, {:delete_room, room_id})
  end

  def delete_room_if_empty(room_id) do
    GenServer.call(__MODULE__,{:delete_room_if_empty, room_id})
  end

  @impl true
  def init(_init_arg) do
    {:ok, %RoomTable{}}
  end

  @impl true
  def handle_call({:create_room, room_id, room_name}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        new_room = Room.new_room(room_id, room_name)
        updated_table = RoomTable.put_room(table, room_id, new_room)
        {:reply, {:ok, new_room}, updated_table}

      _existing ->
        {:reply, {:error, :room_exists}, table}
    end
  end

  @impl true
  def handle_call(:list_rooms, _from, table) do
    rooms = RoomTable.list_rooms(table)
    {:reply, {:ok, rooms}, table}
  end

  @impl true
  def handle_call({:join_room, room_id, user_id, username}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      room ->
        if Room.has_user?(room, user_id) do
          {:reply, {:ok, room}, table}
        else
          updated_room = Room.add_user(room, user_id, username)
          updated_table = RoomTable.put_room(table, room_id, updated_room)
          {:reply, {:ok, updated_room}, updated_table}
        end
    end
  end

  @impl true
  def handle_call({:get_room, room_id}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil -> {:reply, {:error, :room_not_found}, table}
      room -> {:reply, {:ok, room}, table}
    end
  end

  @impl true
  def handle_call({:user_in_room?, room_id, user_id}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      room ->
        result = Room.has_user?(room, user_id)
        {:reply, {:ok, result}, table}
    end
  end

  @impl true
  def handle_call({:leave_room, room_id, user_id}, _from, table) do
    case RoomTable.get_room(table,room_id) do
      nil -> {:reply, {:error, :room_not_found}, table}
      room ->
        updated_room = Room.remove_user(room, user_id)
        updated_table = RoomTable.put_room(table, room_id, updated_room)

        if updated_room.users == [] do
          # send a msg to self() in 3000ms
          Process.send_after(self(), {:delete_room_if_empty, room_id}, 15_000)
        end

        {:reply, {:ok, updated_room}, updated_table}
    end
  end

  @impl true
  def handle_call({:delete_room, room_id}, _from, table) do
    case RoomTable.get_room(table, room_id) do
       nil -> {:reply, {:error, :room_not_found}, table}
       _room ->
         updated_table = RoomTable.delete_room(table, room_id)
         {:reply, {:ok, room_id}, updated_table}
     end
  end

  @impl true
  def handle_call({:delete_room_if_empty, room_id}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      %Room{users: []} ->
        updated_table = RoomTable.delete_room(table, room_id)
        {:reply, {:ok, room_id}, updated_table}
      _ ->
        {:reply, {:ok, :room_not_empty}, table}
    end
  end

  @impl true
  def handle_call({:add_message, room_id, from, from_id, msg}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      room ->
        msg_id = :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
        updated_room = Room.add_message(room, from, from_id, msg, msg_id)
        updated_table = RoomTable.put_room(table, room_id, updated_room)
        {:reply, {:ok, msg_id}, updated_table}
    end
  end

  @impl true
   def handle_info({:delete_room_if_empty, room_id}, table) do
     case RoomTable.get_room(table, room_id) do
       nil ->
         {:noreply, table}
       %Room{users: []} ->
          updated_table = RoomTable.delete_room(table, room_id)
          raw_rooms = RoomTable.list_rooms(updated_table)
          new_rooms = Enum.map(raw_rooms, fn %Room{ room_id: id, room_name: name, users: users } ->
            user_count = length(users)
            %{room_id: id, room_name: name, user_count: user_count}
            end)
         ServerWeb.Endpoint.broadcast!("room:lobby", "rooms-update", %{rooms: new_rooms})
         {:noreply, updated_table}
       _room ->
         {:noreply, table}
     end
   end
end
