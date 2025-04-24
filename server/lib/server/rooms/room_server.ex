defmodule Server.Rooms.RoomServer do
  @moduledoc """
  GenServer implementation for room management.
  """
  use GenServer

  alias Server.Rooms.Room
  alias Server.Rooms.RoomTable
  alias Server.Rooms.Presence

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %RoomTable{}, [name: __MODULE__] ++ opts)
  end

  def create_room(room_id, room_name) do
    GenServer.call(__MODULE__, {:create_room, room_id, room_name})
  end

  def get_room(room_id) do
    GenServer.call(__MODULE__, {:get_room, room_id})
  end

  def list_rooms do
    GenServer.call(__MODULE__, :list_rooms)
  end

  def delete_room(room_id) do
    GenServer.call(__MODULE__, {:delete_room, room_id})
  end

  def join_room(room_id, user_id, username) do
    GenServer.call(__MODULE__, {:join_room, room_id, user_id, username})
  end

  def leave_room(room_id, user_id) do
    GenServer.call(__MODULE__, {:leave_room, room_id, user_id})
  end

  def add_message(room_id, from, msg) do
    GenServer.call(__MODULE__, {:add_message, room_id, from, msg})
  end

  def user_in_room?(room_id, user_id) do
    GenServer.call(__MODULE__, {:user_in_room?, room_id, user_id})
  end

  def get_room_users(room_id) do
    GenServer.call(__MODULE__, {:get_room_users, room_id})
  end

  def track_presence(room_id, user_id, meta) do
    topic = "room:#{room_id}"
    Presence.track(self(), topic, user_id, meta)
  end

  def list_present_users(room_id) do
    topic = "room:#{room_id}"
    Presence.list(topic)
  end

  # Server Callbacks

  @impl true
  def init(table) do
    {:ok, table}
  end

  @impl true
  def handle_call({:create_room, room_id, room_name}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        new_room = Room.new(room_id, room_name)
        updated_table = RoomTable.put_room(table, room_id, new_room)
        {:reply, {:ok, new_room}, updated_table}
      _room ->
        {:reply, {:error, :room_exists}, table}
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
  def handle_call(:list_rooms, _from, table) do
    rooms = RoomTable.list_rooms(table)
    {:reply, {:ok, rooms}, table}
  end

  @impl true
  def handle_call({:delete_room, room_id}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      _room ->
        updated_table = RoomTable.delete_room(table, room_id)
        {:reply, :ok, updated_table}
    end
  end

  @impl true
  def handle_call({:join_room, room_id, user_id, username}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      room ->
        if Room.has_user?(room, user_id) do
          {:reply, {:error, :user_already_in_room}, table}
        else
          updated_room = Room.add_user(room, user_id, username)
          updated_table = RoomTable.put_room(table, room_id, updated_room)
          {:reply, {:ok, updated_room}, updated_table}
        end
    end
  end

  @impl true
  def handle_call({:leave_room, room_id, user_id}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      room ->
        updated_room = Room.remove_user(room, user_id)
        updated_table = RoomTable.put_room(table, room_id, updated_room)
        {:reply, {:ok, updated_room}, updated_table}
    end
  end

  @impl true
  def handle_call({:add_message, room_id, from, msg}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      room ->
        msg_id = :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
        updated_room = Room.add_message(room, from, msg, msg_id)
        updated_table = RoomTable.put_room(table, room_id, updated_room)
        {:reply, {:ok, msg_id}, updated_table}
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
  def handle_call({:get_room_users, room_id}, _from, table) do
    case RoomTable.get_room(table, room_id) do
      nil ->
        {:reply, {:error, :room_not_found}, table}
      room ->
        users = Room.get_users(room)
        {:reply, {:ok, users}, table}
    end
  end
end
