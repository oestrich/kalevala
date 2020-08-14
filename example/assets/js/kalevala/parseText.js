const arrayWrap = (data) => {
  if(!(data instanceof Array)){
    data = [data];
  }

  return data;
};

const generateTagId = () => {
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
};

class Line {
  constructor(text, id) {
    this.id = id || generateTagId();
    this.children = arrayWrap(text);
  }
}

const LineBreak = {};

const splitString = (string) => {
  let strings = string.split("\n").map(s => [LineBreak, s]).flat().slice(1);

  let reducer = (context, string) => {
    if (string === LineBreak) {
      context.strings = context.strings.concat([context.current, LineBreak]);
      context.current = [];
    } else {
      context.current.push(string);
    }

    return context;
  };

  let context = strings.reduce(reducer, {strings: [], current: []});

  context.strings = context.strings.concat([context.current]);
  context.strings.id = generateTagId();

  return context.strings;
}

const flattenChildren = (children) => {
  let reducer = (context, child) => {
    if (child === LineBreak) {
      context.children = context.children.concat([context.current, LineBreak]);
      context.current = [];
    } else {
      context.current = context.current.concat(arrayWrap(child));
    }

    return context;
  };

  let context = children.reduce(reducer, {children: [], current: []});
  children = context.children.concat([context.current]);
  children.id = generateTagId();
  return children;
};

const parseTag = (tag) => {
  let children;

  if (typeof tag === "string") {
    children = splitString(tag).map(strings => {
      if (strings instanceof Array) {
        let children = strings.map(string => {
          return { id: generateTagId(), name: "string", text: string };
        });

        children.id = generateTagId();
        return children;
      }

      // LineBreak
      return strings;
    });

    children.id = generateTagId();
    return children;
  };

  if (tag instanceof Array) {
    let children = tag.map(parseTag).flat();
    children.id = generateTagId();
    return children;
  }

  children = tag.children.map(parseTag).flat();
  children = flattenChildren(children).map((children) => {
    if (children === LineBreak) {
      return LineBreak;
    }

    children = arrayWrap(children);
    children.id = generateTagId();

    return { ...tag, id: generateTagId(), children };
  });

  children.id = generateTagId();
  return children;
};

const parseText = (input) => {
  let children = arrayWrap(input).map(parseTag).flat();

  return flattenChildren(children).filter((tag) => {
    return tag != LineBreak;
  }).map((tag) => {
    return new Line(tag);
  });
};

export default parseText;
export { Line, LineBreak, parseTag };
