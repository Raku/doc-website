let websocketPort = 443;
let websocketHost = 'finanalyst.org';
//render callable added configuration data
//let websocketHost = xxxx;

// credit: This javascript file is adapted from
// https://fjolt.com/article/javascript-websockets
// @connect
// Connect to the websocket
let socket;
// This will let us create a connection to our Server websocket.
// For this to work, your websocket needs to be running with node index.js
const connect = function() {
    // Return a promise, which will wait for the socket to open
    return new Promise((resolve, reject) => {
        // This calculates the link to the websocket.
        const socketProtocol = 'wss:';
        const socketUrl = `${socketProtocol}//${websocketHost}/raku_repl`;
        socket = new WebSocket(socketUrl);

        // This will fire once the socket opens
        socket.onopen = (e) => {
            // Send a little test data, which we can use on the server if we want
            socket.send(JSON.stringify({ "loaded" : true }));
            // Resolve the promise - we are connected
            resolve();
        }

        // This will fire when the server sends the user a message
        socket.onmessage = (data) => {
            let parsedData = JSON.parse(data.data);
            if (parsedData.connection == 'Confirmed') {
                document.getElementById('raku-connection').style.visibility = 'hidden';
                document.getElementById('raku-evaluate').disabled = false;
            }
            const resOut = document.getElementById('raku-ws-stdout');
            const resErr = document.getElementById('raku-ws-stderr');
            resOut.textContent = parsedData.stdout;
            resErr.textContent = parsedData.stderr;
        }
        // This will fire on error
        socket.onerror = (e) => {
            // Return an error if any occurs
            console.log(e);
            resolve();
            // Try to connect again
            connect();
        }
    });
}

// @isOpen
// check if a websocket is open
const isOpen = function(ws) {
    return ws.readyState === ws.OPEN
}
// functions to use cookie to manage status of Repl bar
// adapted from Javascript.info, function returns the value of replBarIsOpen cookie,
// or true if not found
function getReplCookie() {
  let matches = document.cookie.match(new RegExp(
    "(?:^|; )" + "replBarIsOpen" + "=([^;]*)"
  ));
  return matches ? decodeURIComponent(matches[1]) : "open";
}
function setReplCookie(status) {
    document.cookie = "replBarIsOpen=" + status + ";samesite=strict;path=/";
}
function openReplBar(status) {
    let barOpen = status == "open" ? 'visible' : 'hidden';
    let imgClose = status == "open" ? 'hidden' : 'visible';
    document.getElementById('raku-input').style.visibility = barOpen;
    document.getElementById('raku-ws-headout').style.visibility = barOpen;
    document.getElementById('raku-ws-headerr').style.visibility = barOpen;
    document.getElementById('Camelia-code').style.visibility = imgClose;
}
// When the document has loaded
document.addEventListener('DOMContentLoaded', function() {
    // Connect to the websocket
    connect();
    // Add elements for output and error messages
    const codeSection = `
        <img id="Camelia-code" title="Click to get Raku evaluation bar"
            src="/assets/images/Camelia.svg"/>
        <div id="raku-input">
            <textarea rows="2" cols="40" id="raku-code" placeholder="Type some Raku code and Click 'Run'"></textarea>
            <button id="raku-evaluate" title="Evaluate Raku code" disabled>Run</button>
            <button id="raku-hide" title="Close evaluation bar">
                <img src="/assets/images/Camelia.svg"/>
                <div class="code-overlay">
                    <span></span>
                    <span></span>
                </div>
            </button>
            <label id="raku-connection">Waiting for connection</label>
        </div>
        <fieldset id="raku-ws-headout"><legend>Output</legend>
            <div id="raku-ws-stdout"></div>
        </fieldset>
        <fieldset id="raku-ws-headerr"><legend>Errors</legend>
            <div id="raku-ws-stderr"></div>
        </fieldset>
    `;
    document.getElementById('raku-repl').innerHTML = codeSection;
    // manage Repl status
    openReplBar( getReplCookie() );

    // And add our event listeners
    document.getElementById('raku-hide').addEventListener('click' , function(e) {
        openReplBar("close");
        setReplCookie("close");
    });
    document.getElementById('Camelia-code').addEventListener('click' , function(e) {
        openReplBar("open");
        setReplCookie("open");
    });
    document.getElementById('raku-evaluate').addEventListener('click', function(e) {
        let code = document.getElementById('raku-code').value;
        if(isOpen(socket)) {
            socket.send(JSON.stringify({
                "code" : code
            }))
        }
    });
});
