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

const chat_input = document.getElementById("chat_input");
const send_button = document.getElementById("send_button");

const message_container = document.getElementById("message_container");

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

let scrollToBottom = () => 
    {
        message_container.scrollTop = message_container.scrollHeight;
    }

let render_message_dom = (messages) =>
{
    messages.forEach(message => 
        {
            const { msg_id, from, from_id, msg } = message;

            if (document.getElementById(msg_id))
                {
                    return; 
                }
                    
                const message_div = document.createElement("div");
                message_div.id = msg_id;
                message_div.className = "mb-2";
                    
                if (from === "Server")
                {
                message_div.innerHTML = `
                <h4 id="${from_id}" class="text-xs sm:text-sm text-gray-500 italic">
                <span id="${msg_id}" class="font-mono font-bold">server#:</span> ${msg}
                </h4>
                `;
                }
                else
                {
                message_div.innerHTML = `
                <h3 id="${from_id} class="text-sm sm:text-base">
                <span id="${msg_id}" class="font-mono font-bold">${from}:</span> ${msg}
                </h3>
                `;
                }
                message_container.appendChild(message_div);
        })
    scrollToBottom();
}

// SOCKET & EVENT LISTENERS 

copy_link_btn.addEventListener("click", () => 
    {
        const room_link = window.location.href;

        navigator.clipboard.writeText(room_link)
            .then(() => 
                {
                    copy_link_btn.textContent = "Copied";
                    setTimeout(() => copy_link_btn.textContent = 'Copy Link', 1500);
                })
            .catch(error => 
                {
                    alert('Failed to copy link. Do it manually');
                })

    })

exit_btn.addEventListener("click", () => 
    {
        channel.push("leave-room")
            .receive("ok", () => 
                {
                    channel.leave();
                    socket.disconnect();
                    window.location.href = "/";
                })
            .receive("error", () => 
                {
                    alert("Failed to leave the room");
                    window.location.href = "/";
                })
    })

send_button.addEventListener("click", () =>
    {
        message = chat_input.value;
        if (message === "")
        {
            return;
        }
        channel.push("new-message", message)
        chat_input.value = "";
    })


channel.on("user-joined", (payload) => 
    {
        //
    })

channel.on("room-info", (payload) => 
    {
        console.log("ROOM-INFO:", payload);
        render_room_id_dom(payload.room.room_id);
        render_room_name_dom(payload.room.room_name);
        render_chat_user_count_dom(payload.room.user_count);
        render_message_dom(payload.room.messages);
    });
    
channel.join()
    .receive("ok", ()=> {})
    .receive("error", () => 
        {
            alert("Rejoining failed");
            window.location.href = "/";
        })