defmodule ServerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :server

  @session_options [
    store: :cookie,
    key: "_server_key",
    signing_salt: "5l2NSBuM",
    same_site: "Lax"
  ]

  socket "/socket", ServerWeb.UserSocket,
    websocket: [
      connect_info: [session: @session_options]
    ],
    longpoll: false

  plug Plug.Static,
    at: "/",
    from: :server,
    gzip: false,
    only: ServerWeb.static_paths()

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ServerWeb.Router
end
