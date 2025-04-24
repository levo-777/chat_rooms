defmodule ServerWeb.UserSocket do
  use Phoenix.Socket

  channel "room:*", ServerWeb.RoomChannel

  @impl true
  def connect(params, socket, _connect_info) do
    IO.puts("Connecting with params: #{inspect(params)}")

    socket = socket
      |> assign(:user_id, params["user_id"])
      |> assign(:username, params["username"])

    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
