import React from "react";
import { connect } from "react-redux";

import { Creators } from "../redux";

class CharacterSelect extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      character: "",
    };
  }

  render() {
    const submitCharacter = () => {
      this.props.selectCharacter(this.state.character);
    };

    const selectClick = (e) => {
      e.preventDefault();
      submitCharacter();
    };

    const onKeyDown = (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        submitCharacter();
      };
    };

    return (
      <div className="h-full bg-white rounded-t-lg overflow-hidden border-t border-l border-r border-gray-400 p-4 px-3 py-10 bg-gray-200 flex justify-center">
        <div className="w-full max-w-xs">
          <h1 className="text-6xl text-center">Kantele</h1>

          <div className="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4">
            <div className="mb-4">
              <input
                autoFocus={true}
                className="input"
                id="character"
                type="text"
                placeholder="Character"
                value={this.state.character}
                onKeyDown={onKeyDown}
                onChange={(e) => { this.setState({ character: e.target.value }) }}/>
            </div>

            <div className="mb-4">
              <input type="button" className="btn-primary" value="Select" onClick={selectClick} />
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default CharacterSelect = connect(null, {
  selectCharacter: Creators.selectCharacter
})(CharacterSelect);
