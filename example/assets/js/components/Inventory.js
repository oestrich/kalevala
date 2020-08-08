import React from "react";
import { connect } from 'react-redux';

import { getEventsInventory } from "../redux";

const Item = ({ itemInstance }) => {
  return (
    <div className="block bg-white roudned p-4 m-2">
      {itemInstance.item.name}
    </div>
  );
};

let Inventory = ({ inventory }) => {
  return (
    <div className="flex flex-col h-full">
      <h3 className="text-xl px-4 pt-4">Inventory</h3>
      <div className="flex-grow overflow-y-scroll">
        {inventory.map((itemInstance) => {
          return (
            <Item key={itemInstance.id} itemInstance={itemInstance} />
          );
        })}
      </div>
    </div>
  );
};

let mapStateToProps = (state) => {
  const inventory = getEventsInventory(state);
  return { inventory };
};

export default Inventory = connect(mapStateToProps)(Inventory);
