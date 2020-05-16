import "../css/app.scss";

import { Client } from "./client";
import Keys from "./kalevala/keys";

import React from "react";
import ReactDOM from "react-dom";

const keys = new Keys();

document.addEventListener('keydown', e => {
  if (!keys.isModifierKeyPressed()) {
    document.getElementById('prompt').focus();
  }
});

window.Components = {
  Client
}

/**
 * ReactPhoenix
 *
 * Copied from https://github.com/geolessel/react-phoenix/blob/master/src/react_phoenix.js
 */
class ReactPhoenix {
  static init() {
    const elements = document.querySelectorAll('[data-react-class]')
    Array.prototype.forEach.call(elements, e => {
      const targetId = document.getElementById(e.dataset.reactTargetId)
      const targetDiv = targetId ? targetId : e
      const reactProps = e.dataset.reactProps ? e.dataset.reactProps : "{}"
      const reactElement = React.createElement(eval(e.dataset.reactClass), JSON.parse(reactProps))
      ReactDOM.render(reactElement, targetDiv)
    })
  }
}

document.addEventListener("DOMContentLoaded", e => {
  ReactPhoenix.init();
})
