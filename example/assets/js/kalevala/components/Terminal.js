import React from "react";
import { connect } from 'react-redux';

import { parse256Color } from "./colors";
import { getSocketLines } from "../redux";
import Tooltip from "./Tooltip";

const tooltipTags = {
  "ep": "Endurance Points",
  "hp": "Health Points",
  "sp": "Skill Points",
};

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

    let textDecoration = null;

    if (attributes.underline === "true") {
      textDecoration = "underline";
    }

    return {
      color: foreground,
      backgroundColor: background,
      textDecoration,
    };
  }

  render() {
    return (
      <span style={this.styleAttributes()}>
        <Tags children={this.props.children} customTags={this.props.customTags} />
      </span>
    );
  }
}

export class SentText extends React.Component {
  render() {
    const color = theme.colors["white"];

    return (
      <span style={{ color: color }}>
        <Tags children={this.props.children} customTags={this.props.customTags} />
      </span>
    );
  }
}

class Tag extends React.Component {
  render() {
    const { customTags, dispatch, tag } = this.props;

    if (typeof tag === "string") {
      return tag;
    }

    if (this.props.customTags[tag.name]) {
      return this.props.customTags[tag.name](tag, customTags, dispatch);
    }

    if (tooltipTags[tag.name]) {
      return (
        <Tooltip text={tooltipTags[tag.name]}>
          <Tags children={tag.children} customTags={this.props.customTags} />
        </Tooltip>
      );
    }

    switch (tag.name) {
      case "color":
        return (
          <ColorTag children={tag.children} attributes={tag.attributes} customTags={this.props.customTags} />
        );

      case "tooltip":
        return (
          <Tooltip text={tag.attributes.text} customTags={this.props.customTags}>
            <Tags children={tag.children} customTags={this.props.customTags} />
          </Tooltip>
        );

      case "sent-text":
        return (
          <SentText children={tag.children} customTags={this.props.customTags} />
        );

      default:
        return (
          <>
            <Tags children={tag.children} customTags={this.props.customTags} />
          </>
        );
    }
  }
}

Tag = connect(() => { return {} })(Tag);

export { Tag };

export class Tags extends React.Component {
  render() {
    let { children } = this.props;

    if(!(children instanceof Array)){
      children = [children];
    }

    let renderChild = (child, i) => {
      if (child instanceof Array) {
        return (
          <Tags key={i} children={child} customTags={this.props.customTags} />
        );
      } else {
        return (
          <Tag key={i} tag={child} customTags={this.props.customTags} />
        );
      }
    }

    return (
      <>
        {children.map(renderChild)}
      </>
    );
  }
}

class Lines extends React.Component {
  render() {
    let { children } = this.props;

    let renderLine = (line) => {
      return (
        <div key={line.id}>
          <Tags children={line.children} customTags={this.props.customTags} />
        </div>
      );
    };

    return (
      <>
        {children.map(renderLine)}
      </>
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
    let lines = this.props.lines;

    let fontFamily = this.props.font;
    let fontSize = this.props.fontSize;
    let lineHeight = this.props.lineHeight;

    const style = {
      fontFamily: `${fontFamily}, monospace`,
      fontSize,
      lineHeight: `${fontSize * lineHeight}px`,
    };

    return (
      <div ref={el => { this.terminal = el; }} className="relative text-gray-500 overflow-y-scroll flex-grow w-full p-4 whitespace-pre-wrap z-10 bg-gray-900" style={style}>
        <Lines children={lines} customTags={this.props.customTags} />
        <div ref={el => { this.el = el; }} />
      </div>
    );
  }
}

let mapStateToProps = (state) => {
  const lines = getSocketLines(state);

  return { font: "Monaco", fontSize: 16, lineHeight: 1.5, lines };
};

export default Terminal = connect(mapStateToProps)(Terminal);
