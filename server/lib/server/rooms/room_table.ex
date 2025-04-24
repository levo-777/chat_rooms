defmodule Server.Rooms.RoomTable do
  @moduledoc """
  Manages the collection of rooms.
  """
  defstruct rooms: %{}

  @doc """
  Gets a room by ID.
  """
  def get_room(%__MODULE__{rooms: rooms}, room_id) do
    Map.get(rooms, room_id)
  end

  @doc """
  Adds or updates a room.
  """
  def put_room(%__MODULE__{rooms: rooms}, room_id, room) do
    %__MODULE__{rooms: Map.put(rooms, room_id, room)}
  end

  @doc """
  Deletes a room by ID.
  """
  def delete_room(%__MODULE__{rooms: rooms}, room_id) do
    %__MODULE__{rooms: Map.delete(rooms, room_id)}
  end

  @doc """
  Lists all rooms.
  """
  def list_rooms(%__MODULE__{rooms: rooms}) do
    Map.values(rooms)
  end
end
