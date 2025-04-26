import socket from "./user_socket"

// SESSION INFO

const session_user_id = window.user_id;
const session_username = window.username;
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

const room_id = window.location.pathname.split("/").pop();

// CONNECTION
let channel = socket.channel(`room:${room_id}`, {})

console.log(session_user_id);
console.log(session_username);
console.log(csrfToken);
console.log(room_id);

// DOM & FUNCTIONS 



// SOCKET & EVENT LISTENERS 
channel.on("room-info", (payload) => 
    {
        console.log(payload);
    })







channel.join();