import React from "react";
import { connect } from 'react-redux';

import { parse256Color } from "./colors";
import { getSocketLines } from "../redux";
import Tooltip from "./Tooltip";

const CustomTagsContext = React.createContext({});

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

export const renderTags = (children) => {
  return (
    <React.Fragment key={children.id}>
      {children.map((child) => {
        return (
          <Tag key={child.id} tag={child} />
        );
      })}
    </React.Fragment>
  );
};

export class ColorTag extends React.Component {
  /**
   * This is static, no need to ever re-render
   */
  shouldComponentUpdate(nextProps, nextState) {
    return false;
  }

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
        {renderTags(this.props.children)}
      </span>
    );
  }
}

export class SentText extends React.Component {
  /**
   * This is static, no need to ever re-render
   */
  shouldComponentUpdate(nextProps, nextState) {
    return false;
  }

  render() {
    const color = theme.colors["white"];

    return (
      <span style={{ color: color }}>
        {renderTags(this.props.children)}
      </span>
    );
  }
}

class Tag extends React.Component {
  render() {
    const customTags = this.context;

    const { dispatch, tag } = this.props;

    if (tag.name === "string") {
      return tag.text;
    }

    if (customTags[tag.name]) {
      const customTag = customTags[tag.name];

      return customTag(tag);
    }

    if (tooltipTags[tag.name]) {
      return (
        <Tooltip text={tooltipTags[tag.name]}>
          {renderTags(tag.children)}
        </Tooltip>
      );
    }

    switch (tag.name) {
      case "color":
        return (
          <ColorTag children={tag.children} attributes={tag.attributes} />
        );

      case "tooltip":
        return (
          <Tooltip text={tag.attributes.text} >
            {renderTags(this.props.children)}
          </Tooltip>
        );

      case "sent-text":
        return (
          <SentText children={tag.children} />
        );

      default:
        return renderTags(tag.children);
    }
  }
}

Tag.contextType = CustomTagsContext;

export { Tag };

class Lines extends React.Component {
  render() {
    let { children } = this.props;

    let renderLine = (line) => {
      return (
        <div key={line.id}>
          {renderTags(line.children)}
        </div>
      );
    };

    return (
      <React.Fragment>
        {children.map(renderLine)}
      </React.Fragment>
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
    const lines = this.props.lines;

    const fontFamily = this.props.font;
    const fontSize = this.props.fontSize;
    const lineHeight = this.props.lineHeight;

    const style = {
      fontFamily: `${fontFamily}, monospace`,
      fontSize,
      lineHeight: `${fontSize * lineHeight}px`,
    };

    return (
      <div ref={el => { this.terminal = el; }} style={style}
        className="relative text-gray-500 overflow-y-scroll flex-grow w-full p-4 whitespace-pre-wrap z-10 bg-gray-900">
        <Lines children={lines} />
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

export { CustomTagsContext };
