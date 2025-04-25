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

let update_room_user_count = (new_user_count) => 
{
    return;
}


let render_room_dom = (rooms) =>
{
    rooms.forEach(({ room_id, room_name, user_count }) => 
        {
            let room_element = document.getElementById(room_id);
            if(room_element)
            {
                //update_room_user_count(room_element);
                return;
            }

            let room_container = document.createElement('div');
            room_container.id = room_id;
            room_container.className = "grid grid-cols-1 sm:grid-cols-4 gap-1 sm:gap-4 p-2 sm:p-4 border-2 border-gray-300 rounded-lg text-xs sm:text-sm";

            let room_title_id_tag = document.createElement("h4");
            room_title_id_tag.className = "p-1 sm:p-2";

            let span_1 = document.createElement("span");
            let span_2 = document.createElement("span");

            span_1.className = "font-mono";
            span_1.innerHTML = `Room ID:&ensp;&ensp;&ensp;`

            span_2.className = "font-bold";
            span_2.innerText = room_id;

            room_title_id_tag.appendChild(span_1);
            room_title_id_tag.appendChild(span_2);
            room_container.appendChild(room_title_id_tag);

            span_1.className = ""
            span_1.innerText = "";

            span_2.className = "";
            span_2.innerText = "";

            let room_title_tag = document.createElement("h4");
            room_title_tag.className = "p-1 sm:p-2";

            span_1.className = "font-normal";
            span_1.innerHTML = `Room Name:&ensp;`;

            span_2.className = "font-bold";
            span_2.innerText = room_name;

            room_title_tag.appendChild(span_1);
            room_title_tag.appendChild(span_2);
            room_container.appendChild(room_title_tag);

            span_1.className = ""
            span_1.innerText = "";

            span_2.className = "";
            span_2.innerText = "";

            new_id = room_id + "-user_count";

            let user_count_tag = document.createElement("h4");
            user_count_tag.className = "p-1 sm:p-2"
            
            span_1.className = "font-normal";
            span_1.innerHTML = `Users:&ensp;`;

            span_2.id = new_id;
            span_2.className = "font-bold";
            span_2.innerText = user_count;

            user_count_tag.appendChild(span_1);
            user_count_tag.appendChild(span_2);

        });
}


// SOCKET AND EVENT LISTENERS

channel.on("rooms-update", (payload) => 
    {
        console.log(payload);
        //remove_old_rooms_dom(payload.rooms);
    })


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
        .receive("ok", (response) => 
            {
                console.log(response);
            })
        .receive("error", (response) => 
            {
                console.log(response);
            });    
    });



channel.join()
    .receive("ok", resp => 
    { 
        console.log("Joined lobby", resp);
        set_username_dom(session_username);
        //remove_old_rooms_dom(resp.rooms); 
      })
    .receive("error", resp => 
      { 
        console.log("Failed to join lobby", resp);
        alert("Failed to join lobby", resp); 
      });
