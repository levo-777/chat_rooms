defmodule Server.Rooms.Room do
  @moduledoc """
  Represents a chat room with users and messages.
  """
  defstruct [:room_id, :room_name, users: [], messages: []]

  @type t :: %__MODULE__{
    room_id: String.t(),
    room_name: String.t(),
    users: [{String.t(), String.t()}],
    messages: [%{from: String.t(), msg: String.t(), msg_id: String.t()}]
  }

  @doc """
  Creates a new room with the given ID and name.
  """
  def new(room_id, room_name) do
    %__MODULE__{
      room_id: room_id,
      room_name: room_name,
      users: [],
      messages: []
    }
  end

  @doc """
  Adds a user to the room.
  """
  def add_user(%__MODULE__{users: users} = room, user_id, username) do
    %{room | users: users ++ [{user_id, username}]}
  end

  @doc """
  Removes a user from the room.
  """
  def remove_user(%__MODULE__{users: users} = room, user_id) do
    %{room | users: Enum.reject(users, fn {uid, _} -> uid == user_id end)}
  end

  @doc """
  Checks if a user is in the room.
  """
  def has_user?(%__MODULE__{users: users}, user_id) do
    Enum.any?(users, fn {uid, _} -> uid == user_id end)
  end

  @doc """
  Adds a message to the room.
  """
  def add_message(%__MODULE__{messages: messages} = room, from, msg, msg_id) do
    new_message = %{from: from, msg: msg, msg_id: msg_id}
    %{room | messages: messages ++ [new_message]}
  end

  @doc """
  Gets all users in the room.
  """
  def get_users(%__MODULE__{users: users}) do
    users
  end
end
