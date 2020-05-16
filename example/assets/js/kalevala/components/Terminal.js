import React from "react";
import { connect } from 'react-redux';

import { parse256Color } from "./colors";
import { getSocketTags } from "../redux";

const theme = {
  colors: {
    black: "#373737",
    red: "#d71e00",
    green: "#5da602",
    yellow: "#cfad00",
    blue: "#417ab3",
    magenta: "#88658d",
    cyan: "#00a7aa",
    white: "#dbded8",
  },

  backgroundColors: {
    black: "#000000",
    red: "#d71e00",
    green: "#5da602",
    yellow: "#cfad00",
    blue: "#417ab3",
    magenta: "#88658d",
    cyan: "#00a7aa",
    white: "#dbded8",
  },
};

export class TextTag extends React.Component {
  render() {
    const { text } = this.props;

    return text;
  }
}

export class ColorTag extends React.Component {
  styleAttributes() {
    const attributes = this.props.attributes;

    let foreground = attributes.foreground;

    if (theme.colors[foreground]) {
      foreground = theme.colors[foreground];
    }

    if (foreground && foreground.includes(",")) {
      foreground = `rgb(${foreground})`;
    }

    if (foreground && foreground.startsWith("256:")) {
      foreground = parse256Color(foreground.replace("256:", ""));
    }

    let background = attributes.background;

    if (theme.backgroundColors[background]) {
      background = theme.backgroundColors[background];
    }

    if (background && background.includes(",")) {
      background = `rgb(${background})`;
    }

    return {
      color: foreground,
      backgroundColor: background,
    };
  }

  render() {
    return (
      <span style={this.styleAttributes()}>
        <Tags children={this.props.children} />
      </span>
    );
  }
}

export class Tag extends React.Component {
  render() {
    const { tag } = this.props;

    if (typeof tag === "string") {
      return (
        <TextTag text={tag} />
      );
    }

    switch (tag.name) {
      case "color":
        return (
          <ColorTag children={tag.children} attributes={tag.attributes} />
        );

      default:
        return (
          <span>
            <Tags children={tag.children} />
          </span>
        );
    }
  }
}

export class Tags extends React.Component {
  render() {
    const { children } = this.props;

    if(!(children instanceof Array)){
      children = [children];
    }

    let renderChild = (child, i) => {
      if (child instanceof Array) {
        return (
          <Tags key={i} children={child} />
        );
      } else {
        return (
          <Tag key={i} tag={child} />
        );
      }
    }

    return (
      <span>
        {children.map(renderChild)}
      </span>
    );
  }
}

class Terminal extends React.Component {
  constructor(props) {
    super(props);

    this.triggerScroll = true;
  }

  componentDidMount() {
    this.scrollToBottom();
  }

  componentDidUpdate() {
    this.scrollToBottom();
  }

  getSnapshotBeforeUpdate() {
    let visibleBottom = this.terminal.scrollTop + this.terminal.clientHeight;
    this.triggerScroll = !(visibleBottom + 250 < this.terminal.scrollHeight);

    return null;
  }

  scrollToBottom() {
    if (this.triggerScroll) {
      this.el.scrollIntoView();
    }
  }

  render() {
    let tags = this.props.tags;

    let fontFamily = this.props.font;
    let fontSize = this.props.fontSize;
    let lineHeight = this.props.lineHeight;

    const style = {
      fontFamily: `${fontFamily}, monospace`,
      fontSize,
      lineHeight: `${fontSize * lineHeight}px`,
    };

    return (
      <div ref={el => { this.terminal = el; }} className="text-gray-500 overflow-y-scroll flex-grow width-full p-4 whitespace-pre-wrap z-10 bg-gray-900" style={style}>
        <Tags children={tags} />
        <div ref={el => { this.el = el; }} />
      </div>
    );
  }
}

let mapStateToProps = (state) => {
  const tags = getSocketTags(state);

  return { font: "Monaco", fontSize: 16, lineHeight: 1.5, tags };
};

export default Terminal = connect(mapStateToProps)(Terminal);
