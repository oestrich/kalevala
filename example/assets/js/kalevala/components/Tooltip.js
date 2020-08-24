import React from 'react';

const isFunction = (obj) => {
  return !!(obj && obj.constructor && obj.call && obj.apply);
};

const Tooltip = ({ children, className, tip }) => {
  if (isFunction(tip)) {
    tip = tip();
  }

  if (tip === null) {
    return (
      <span className={`inline-block ${className}`}>
        {children}
      </span>
    );
  }

  return (
    <span className={`tooltip-hover inline-block ${className}`}>
      {children}
      <div className="tooltip">{tip}</div>
    </span>
  );
};

export default Tooltip;
