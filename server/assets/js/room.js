import socket from "./user_socket"

// SESSION INFO

const session_user_id = window.user_id;
const session_username = window.username;
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
const room_id = window.location.pathname.split("/").pop();

// CONNECTION
let channel = socket.channel(`room:${room_id}`, {})

// DOM & FUNCTIONS 
const chat_room_id = document.getElementById("chat_room_id");
const chat_room_name = document.getElementById("chat_room_name");
const chat_user_count = document.getElementById("chat_user_count");

const copy_link_btn = document.getElementById("copy_link_btn");
const exit_btn = document.getElementById("exit_btn");

let render_room_id_dom = (room_id) =>
{
    chat_room_id.innerText = room_id;
}

let render_room_name_dom = (room_name) =>
{
    chat_room_name.innerText = room_name;
}

let render_chat_user_count_dom = (user_count) =>
{
    chat_user_count.innerText = user_count;
}


// SOCKET & EVENT LISTENERS 

channel.on("user-joined", (payload) => 
    {
        console.log("user-joined ", payload);
    })

channel.on("room-info", (payload) => 
    {
        render_room_id_dom(payload.room.room_id);
        render_room_name_dom(payload.room.room_name);
        render_chat_user_count_dom(payload.room.user_count);
    });









channel.join();