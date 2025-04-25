defmodule Server.Rooms.Room do

  defstruct [:room_id, :room_name, users: [],messages: []]

  @type t :: %__MODULE__{
    room_id: String.t(),
    room_name: String.t(),
    users: [{String.t(), String.t()}],
    messages: [%{from: String.t(), msg: String.t(), msg_id: String.t()}]
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

  def has_user?(%__MODULE__{users: users}, user_id) do
    Enum.any?(users, fn {uid, _} -> uid == user_id end)
  end

end
