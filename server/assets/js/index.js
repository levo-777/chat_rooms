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
                set_username_dom(data.username);
            });
}




// SOCKET AND EVENT LISTENERS 

new_username_button.addEventListener("click", ()=> 
{
    username = username_input_tag.value;
    if ( username === "")
        {
            alert("Username require");
            return;
        }
    set_username_post_req(username);
});

channel.join()
  .receive("ok", resp => 
    { 
        console.log("Joined lobby", resp);
        set_username_dom(session_username); 
    })
  .receive("error", resp => 
    { 
        console.log("Failed to join lobby", resp);
        alert("Failed to join lobby", resp); 
    })