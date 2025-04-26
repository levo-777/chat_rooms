import socket from "./user_socket"
// SESSION INFO

const session_user_id = window.user_id;
const session_username = window.username;
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

// CONNECTION
let channel = socket.channel("room:lobby", {})

// DOM AND FUNCTIONS

const username_title_tag = document.querySelector("#username_title_tag");
const username_input_tag = document.querySelector("#username_input_tag");
const new_username_button = document.querySelector("#new_username_button");

const new_room_input_tag = document.querySelector("#new_room_input_tag");
const new_room_button = document.querySelector("#new_room_button");

const rooms_list = document.querySelector("#rooms_list");

let set_username_dom = (username) => 
{
    username_title_tag.innerText = username;
    username_input_tag.value = "";
}

let set_username_post_req = (username) =>
{
    fetch("/set-username", 
        {
            method: "POST",
            headers:
                {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": csrfToken,
                },
            body: JSON.stringify({ username: username }),
        })
        .then(response => response.json())
        .then(data => 
            {
                if(!data.success)
                {
                    alert(data.message || "Username update failed!");
                }
                set_username_dom(data.username);
            })
        .catch(error => 
            {
                alert("Error setting username:", error);
            });
        
}

let remove_old_rooms_dom = (rooms) =>
{
    const valid_room_ids = rooms.map(room => room.room_id);
    dom_ids = Array.from(rooms_list.children).map(dom_element => dom_element.id);
    
    old_ids = dom_ids.filter(id => !valid_room_ids.includes(id));
    
    old_ids.forEach(id => { rooms_list.removeChild(document.getElementById(id)) });
}

let update_room_user_count = (room_id, new_user_count) => 
{
    let user_count_id = `${room_id}-user_count`;
    let user_count_dom = document.getElementById(user_count_id);
    if (!user_count_dom)
    {
        return;
    } 
  
    
    if (user_count_dom.innerText.trim() !== String(new_user_count)) 
    {
      user_count_dom.innerText = new_user_count;
    }
}

let render_room_dom = (rooms) => 
{
    rooms.forEach(({ room_id, room_name, user_count }) => {
        let room_element = document.getElementById(room_id);
        if (room_element) 
        {
            update_room_user_count(room_id, user_count);
            return;
        }

        let room_container = document.createElement('div');
        room_container.id = room_id;
        room_container.className = "grid grid-cols-1 sm:grid-cols-4 gap-1 sm:gap-4 p-2 sm:p-4 border-2 border-gray-300 rounded-lg text-xs sm:text-sm";

        // --- Room ID ---
        let room_title_id_tag = document.createElement("h4");
        room_title_id_tag.className = "p-1 sm:p-2";

        let span_id_label = document.createElement("span");
        span_id_label.className = "font-mono";
        span_id_label.innerHTML = `Room ID:&ensp;&ensp;`;

        let span_id_value = document.createElement("span");
        span_id_value.className = "font-bold";
        span_id_value.innerText = room_id;

        room_title_id_tag.appendChild(span_id_label);
        room_title_id_tag.appendChild(span_id_value);
        room_container.appendChild(room_title_id_tag);

        // --- Room Name ---
        let room_title_tag = document.createElement("h4");
        room_title_tag.className = "p-1 sm:p-2";

        let span_name_label = document.createElement("span");
        span_name_label.className = "font-mono";
        span_name_label.innerHTML = `Room Name:&ensp;`;

        let span_name_value = document.createElement("span");
        span_name_value.className = "font-bold";
        span_name_value.innerText = room_name;

        room_title_tag.appendChild(span_name_label);
        room_title_tag.appendChild(span_name_value);
        room_container.appendChild(room_title_tag);

        // --- User Count ---
        let user_count_tag = document.createElement("h4");
        user_count_tag.className = "p-1 sm:p-2";

        let span_user_label = document.createElement("span");
        span_user_label.className = "font-mono";
        span_user_label.innerHTML = `Users:&ensp;`;

        let span_user_value = document.createElement("span");
        span_user_value.id = room_id + "-user_count";
        span_user_value.className = "font-bold";
        span_user_value.innerText = user_count;

        user_count_tag.appendChild(span_user_label);
        user_count_tag.appendChild(span_user_value);
        room_container.appendChild(user_count_tag);

        // --- Join Button ---
        let button_container = document.createElement("div");
        button_container.className = "p-1 sm:p-2 flex items-center justify-center";

        let join_button = document.createElement("button");
        join_button.id = room_id + "-join_button";
        join_button.className = "w-full sm:w-auto h-8 sm:h-10 sm:h-12 px-2 sm:px-4 bg-blue-500 text-white font-semibold rounded-lg hover:bg-blue-600 focus:outline-none";
        join_button.innerText = "JOIN";

        join_button.addEventListener("click", (event) => 
            {
                let button_id = event.target.id;
                let room_id = button_id.split("-")[0];
                try
                {
                    window.location.href = `/rooms/${room_id}`;
                }
                catch(error)
                {
                    alert("Error: Unable to join the room.");
                    console.log(error);
                }
            });

        button_container.appendChild(join_button);
        room_container.appendChild(button_container);

        rooms_list.appendChild(room_container);
    });
}


// SOCKET AND EVENT LISTENERS

channel.on("rooms-update", (payload) => 
    {
        remove_old_rooms_dom(payload.rooms);
        render_room_dom(payload.rooms);
        new_room_input_tag.value = "";
    });

channel.on("redirect-ready", (payload) => 
    {
        try
        {
            window.location.href = "/rooms/" + payload.room_id;
        }
        catch(error)
        {
            alert("Redirection Failed")
        }
    });


new_username_button.addEventListener("click", ()=> 
    {
        username = username_input_tag.value;
        if ( username === "")
            {
                alert("Username required");
                return;
            }
            set_username_post_req(username);
    });


new_room_button.addEventListener("click", ()=> 
    {
        room_name = new_room_input_tag.value;
        if ( room_name === "")
        {
            alert("Room Name required");
            return;
        }
        channel.push("create-room", {room_name: room_name})   
    });



channel.join()
    .receive("ok", resp => 
    {
        set_username_dom(session_username);
        remove_old_rooms_dom(resp.rooms);
        render_room_dom(resp.rooms); 
      })
    .receive("error", resp => 
      {
        alert("Failed to join lobby", resp); 
      });
