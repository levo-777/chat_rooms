defmodule Server.Rooms.Presence do
  use Phoenix.Presence,
    otp_app: :server,
    pubsub_server: Server.PubSub
end
