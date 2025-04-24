import socket from "./user_socket"

let channel = socket.channel("room:lobby", {})

channel.join()
  .receive("ok", resp => { console.log("Joined lobby", resp) })
  .receive("error", resp => { console.log("Failed to join lobby", resp) })