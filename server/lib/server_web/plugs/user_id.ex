defmodule ServerWeb.Plugs.UserID do
  import Plug.Conn

  @behaviour Plug
  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)

    case get_session(conn, :user_id) do
      nil ->
        user_id = :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
        conn
        |> put_session(:user_id, user_id)
        |> assign(:user_id, user_id)

      existing_id ->
        assign(conn, :user_id, existing_id)
    end
  end

end
