import React from "react";

const borderColor = (side) => {
  switch (side) {
    case "bottom":
      return "border-t-2";

    case "left":
      return "border-r-2";

    case "right":
      return "border-l-2";

    case "top":
      return "border-b-2";
  };
};

const Sidebar = ({ children, side, width }) => {
  return (
    <div className={`text-black bg-gray-200 border-blue-200 ${borderColor(side)} ${width}`}>
      {children}
    </div>
  );
};

export {Sidebar};
