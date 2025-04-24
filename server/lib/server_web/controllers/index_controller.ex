defmodule ServerWeb.IndexController do
  use ServerWeb, :controller

  def index(conn, _params) do
    render(conn, :index, layout: false)
  end

  def set_username(conn, %{"username" => "" })  do
    json(conn, %{success: false, message: "Username cannot be empty"})
  end

  def set_username(conn, %{"username" => username}) when byte_size(username) > 13 do
    json(conn, %{sucess: false, message: "Username cannot be longer than 12 characters"})
  end

  def set_username(conn,%{"username" => username}) do
    conn
    |> put_session(:username, username)
    |> json(%{success: true, username: username})
  end

end
