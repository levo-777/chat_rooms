defmodule ServerWeb.Router do
  use ServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug ServerWeb.Plugs.UserID
    plug ServerWeb.Plugs.Username
    plug :fetch_live_flash
    plug :put_root_layout, html: {ServerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ServerWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

end
