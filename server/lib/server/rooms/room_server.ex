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
end
