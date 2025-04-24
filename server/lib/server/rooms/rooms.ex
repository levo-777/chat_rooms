defmodule Server.Rooms do
  @moduledoc """
  Public API for chat room management.
  Abstracts the GenServer implementation.
  """

  alias Server.Rooms.RoomServer

  @doc """
  Creates a new room with the given ID and name.
  """
  def create_room(room_id, room_name) do
    RoomServer.create_room(room_id, room_name)
  end

  @doc """
  Gets room details by ID.
  """
  def get_room(room_id) do
    RoomServer.get_room(room_id)
  end

  @doc """
  Lists all available rooms with summary information.
  """
  def list_rooms do
    case RoomServer.list_rooms() do
      {:ok, rooms} ->
        {:ok, Enum.map(rooms, fn room ->
          %{
            room_id: room.room_id,
            room_name: room.room_name,
            user_count: length(room.users)
          }
        end)}
      error -> error
    end
  end

  @doc """
  Deletes a room by ID.
  """
  def delete_room(room_id) do
    RoomServer.delete_room(room_id)
  end

  @doc """
  Adds a user to a room if they're not already in it.
  """
  def join_room(room_id, user_id, username) do
    RoomServer.join_room(room_id, user_id, username)
  end

  @doc """
  Removes a user from a room.
  """
  def leave_room(room_id, user_id) do
    RoomServer.leave_room(room_id, user_id)
  end

  @doc """
  Adds a message to a room.
  """
  def add_message(room_id, from, msg) do
    RoomServer.add_message(room_id, from, msg)
  end

  @doc """
  Checks if a user is in a room.
  """
  def user_in_room?(room_id, user_id) do
    RoomServer.user_in_room?(room_id, user_id)
  end

  @doc """
  Gets all users in a room.
  """
  def get_room_users(room_id) do
    RoomServer.get_room_users(room_id)
  end

  @doc """
  Tracks user presence in a room using Phoenix.Presence.
  """
  def track_presence(room_id, user_id, meta) do
    RoomServer.track_presence(room_id, user_id, meta)
  end

  @doc """
  Lists present users in a room.
  """
  def list_present_users(room_id) do
    RoomServer.list_present_users(room_id)
  end
end
