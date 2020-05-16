class Socket {
  constructor(path) {
    this.path = path;
  }

  connect() {
    this.socket = new WebSocket(`ws://${location.host}${this.path}`);

    this.socket.onmessage = (message) => {
      let event = JSON.parse(message.data);
      if (this.onEvent) {
        this.onEvent(event);
      }
    };

    this.socket.onopen = (e) => {
      console.log("Socket opened");

      if (this.onOpen) {
        this.onOpen(e);
      }
    };

    this.socket.onclose = (e) => {
      console.log("Socket closed");

      clearInterval(this.pingTimeout);

      if (this.onClose) {
        this.onClose(e);
      }
    };

    this.socket.onerror = (e) => {
      console.log("Socket error");

      if (this.onError) {
        this.onError(e);
      }
    };

    this.pingTimeout = setInterval(() => {
      this.send({type: "system/ping"});
    }, 5000);
  }

  send(event) {
    if (this.socket.readyState != WebSocket.OPEN) {
      console.log("Trying to send an event but the socket is closed", event);
      return;
    }

    this.socket.send(JSON.stringify(event));
  }

  onEvent(fun) {
    this.onEvent = fun;
  }

  onOpen(fun) {
    this.onOpen = fun;
  }

  onClose(fun) {
    this.onClose = fun;
  }

  onError(fun) {
    this.onError = fun;
  }
}


class ClientSocket {
  constructor(client) {
    this.client = client;
  }

  join() {
    this.socket = new Socket("/socket");
    this.socket.connect();
    this.connect();
  }

  connect() {
    this.socket.onEvent((event) => {
      if (event.type == "system/multiple") {
        event.data.forEach((event) => {
          this.client.receivedEvent(event);
        });

        return;
      }

      this.client.receivedEvent(event);
    });

    this.socket.onOpen(() => {
      this.client.connected();
    });

    this.socket.onClose(() => {
      this.client.disconnected();
    });

    this.socket.onError(() => {
      this.client.disconnected();
    });
  }

  send(event) {
    this.socket.send(event);
  }
}

export {ClientSocket};
