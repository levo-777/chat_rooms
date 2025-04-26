defmodule Server.Rooms.Room do

  defstruct [:room_id, :room_name, users: [],messages: []]

  @type t :: %__MODULE__{
    room_id: String.t(),
    room_name: String.t(),
    users: [{String.t(), String.t()}],
    messages: [%{from: String.t(), from_id: String.t(), msg: String.t(), msg_id: String.t()}]
  }

  def new_room(room_id, room_name) do
    %__MODULE__{
      room_id: room_id,
      room_name: room_name,
      users: [],
      messages: []
    }
  end

  def add_user(%__MODULE__{users: users} = room, user_id, username) do
    %{room | users: users ++ [{user_id, username}]}
  end

  def remove_user(%__MODULE__{users: users} = room, user_id) do
    %{room | users: Enum.reject(users, fn {uid, _} -> uid == user_id end)}
  end

  def get_users(%__MODULE__{users: users}) do
    users
  end

  def has_user?(%__MODULE__{users: users}, user_id) do
    Enum.any?(users, fn {uid, _} -> uid == user_id end)
  end

  def add_message(%__MODULE__{messages: messages} = room, from, from_id, msg, msg_id) do
    new_message = %{from: from, from_id: from_id, msg: msg, msg_id: msg_id}
    %{room | messages: messages ++ [new_message]}
  end

end
