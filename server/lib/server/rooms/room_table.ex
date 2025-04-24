defmodule Server.Rooms.RoomTable do
  defstruct rooms: %{}

  def get_room(%__MODULE__{rooms: rooms}, room_id) do
    Map.get(rooms, room_id)
  end

  def put_room(%__MODULE__{rooms: rooms}, room_id, room_struct) do
    %__MODULE__{rooms: Map.put(rooms, room_id, room_struct)}
  end

  def delete_room(%__MODULE__{rooms: rooms}, room_id) do
    %__MODULE__{rooms: Map.delete(rooms, room_id)}
  end

  def list_rooms(%__MODULE__{rooms: rooms}) do
    Map.values(rooms)
  end
end
