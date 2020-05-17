import React from 'react';
import { connect } from 'react-redux';

import ConnectionStatus from "./ConnectionStatus";

import {
  Creators,
  getSocketPromptType,
  getPromptDisplayText,
} from "../redux";

class Prompt extends React.Component {
  constructor(props) {
    super(props);

    this.buttonSendMessage = this.buttonSendMessage.bind(this);
    this.onKeyDown = this.onKeyDown.bind(this);
    this.onTextChange = this.onTextChange.bind(this);

    this.shouldSelect = false;
  }

  buttonSendMessage(e) {
    e.preventDefault();
    this.sendMessage();
  }

  onKeyDown(e) {
    switch (e.keyCode) {
      case 13: {
        this.sendMessage();
        break;
      }

      case 38: { // up
        e.preventDefault();
        this.props.promptHistoryScrollBackward();
        this.shouldSelect = true;
        break;
      }

      case 40: { // down
        e.preventDefault();
        this.props.promptHistoryScrollForward();
        this.shouldSelect = true;
        break;
      }
    }
  }

  sendMessage() {
    this.props.promptHistoryAdd();
    this.prompt.setSelectionRange(0, this.prompt.value.length);

    this.props.socketSendEvent({
      topic: "system/send",
      data: {
        text: this.props.displayText
      }
    });
  }

  onTextChange(e) {
    this.props.promptSetCurrentText(e.target.value);
  }

  componentDidUpdate() {
    if (this.shouldSelect) {
      this.shouldSelect = false;
      this.prompt.setSelectionRange(0, this.prompt.value.length);
    }
  }

  render() {
    return (
      <div className="flex p-4">
        <ConnectionStatus />

        <input id="prompt"
          value={this.props.displayText}
          onChange={this.onTextChange}
          type="text"
          className="input"
          autoFocus={true}
          onKeyDown={this.onKeyDown}
          autoCorrect="off"
          autoCapitalize="off"
          autoComplete="off"
          spellCheck="false"
          ref={el => { this.prompt = el; }} />

        <button id="send" className="btn-primary" onClick={this.buttonSendMessage}>Send</button>
      </div>
    );
  }
}

let mapStateToProps = (state) => {
  let displayText = getPromptDisplayText(state);
  return { displayText };
};

export default Prompt = connect(mapStateToProps, {
  promptClear: Creators.promptClear,
  promptHistoryAdd: Creators.promptHistoryAdd,
  promptHistoryScrollBackward: Creators.promptHistoryScrollBackward,
  promptHistoryScrollForward: Creators.promptHistoryScrollForward,
  promptSetCurrentText: Creators.promptSetCurrentText,
  socketSendEvent: Creators.socketSendEvent,
})(Prompt);
