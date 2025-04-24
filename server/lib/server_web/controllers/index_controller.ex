defmodule ServerWeb.IndexController do
  use ServerWeb, :controller

  def index(conn, _params) do
    render(conn, :index, layout: false)
  end

  def set_username(conn, %{"username" => username}) do
    conn
    |> put_session(:username, username)
    |> json(%{success: true, username: username});
  end

end
