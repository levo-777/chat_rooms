defmodule Server.Rooms.Presence do
  use Phoenix.Presence,
    otp_app: :Server,
    pubsub_server: Server.PubSub
end
