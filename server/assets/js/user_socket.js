import { Socket } from "phoenix"

const user_id = window.user_id || "";
const username = window.username || "";

let socket = new Socket("/socket", {
  params: { user_id, username }
})

socket.connect();

export default socket;
