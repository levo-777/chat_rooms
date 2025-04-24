defmodule ServerWeb.Plugs.Username do
  import Plug.Conn

  @behaviour Plug
  def init(opts), do: opts

  def call(conn,_opts) do
    conn = fetch_session(conn)

    case get_session(conn, :username) do
     nil ->
      username_id_suffix = :crypto.strong_rand_bytes(3) |> Base.encode16(case: :lower)
      username = "guest-" <> username_id_suffix
      conn
      |> put_session(:username, username)
      |> assign(:username, username)

    existing_username ->
      assign(conn, :username, existing_username)
    end
  end

end
