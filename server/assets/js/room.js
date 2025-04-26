import socket from "./user_socket"

// SESSION INFO

const session_user_id = window.user_id;
const session_username = window.username;
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

console.log(session_user_id);
console.log(session_username);
console.log(csrfToken);