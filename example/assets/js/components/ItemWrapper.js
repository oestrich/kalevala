import React from "react";

export default class ItemWrapper extends React.Component {
  constructor(props) {
    super(props);

    this.showTooltip = this.showTooltip.bind(this);
    this.startHoverTimeout = this.startHoverTimeout.bind(this);

    this.state = {
      showTooltip: false,
    };
  }

  showTooltip() {
    clearTimeout(this.timer);
    this.setState({showTooltip: true});
  }

  startHoverTimeout() {
    this.timer = setTimeout(() => {
      this.setState({showTooltip: false});
    }, 500);
  }

  render() {
    const { attributes, children } = this.props;
    const { showTooltip } = this.state;

    return (
      <div className="tooltip-hover inline-block" onMouseEnter={this.showTooltip} onMouseLeave={this.startHoverTimeout}>
        <span className="cursor-pointer">
          {this.props.children}
        </span>
        <div className={`tooltip font-sans opacity-100 ${showTooltip ? "block" : ""}`}>
          <h3 className="text-xl">{attributes.name}</h3>
          <p>{attributes.description}</p>
        </div>
      </div>
    );
  }
}
