import parseText, { Line, LineBreak, parseTag } from "./parseText";

describe("breaking apart a single tag", () => {
  test("has no line breaks", () => {
    let tag = {
      name: "color",
      attributes: { foreground: "red" },
      children: ["text"],
    };

    let tags = parseTag(tag); 

    expect(tags).toEqual([tag]);
  });

  test("one line break", () => {
    let tag = {
      name: "color",
      attributes: { foreground: "red" },
      children: ["one\nline"],
    };

    let tags = parseTag(tag); 

    expect(tags).toEqual([
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["one"],
      },
      LineBreak,
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["line"],
      }
    ]);
  });

  test("many line breaks", () => {
    let tag = {
      name: "color",
      attributes: { foreground: "red" },
      children: ["one line\ntwo line\nthree line"],
    };

    let tags = parseTag(tag); 

    expect(tags).toEqual([
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["one line"],
      },
      LineBreak,
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["two line"],
      },
      LineBreak,
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["three line"],
      },
    ]);
  });

  test("multiple children", () => {
    let tag = {
      name: "color",
      attributes: { foreground: "red" },
      children: ["one\nline", "two\nline"],
    };

    let tags = parseTag(tag); 

    expect(tags).toEqual([
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["one"],
      },
      LineBreak,
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["line", "two"],
      },
      LineBreak,
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["line"],
      }
    ]);
  });

  test("tags as children", () => {
    let tag = {
      name: "color",
      attributes: { foreground: "red" },
      children: [
        "one\nline",
        {
          name: "color",
          attributes: { foreground: "green" },
          children: ["two\nline"],
        },
      ],
    };

    let tags = parseTag(tag); 

    expect(tags).toEqual([
      {
        name: "color",
        attributes: { foreground: "red" },
        children: ["one"],
      },
      LineBreak,
      {
        name: "color",
        attributes: { foreground: "red" },
        children: [
          "line",
          {
            name: "color",
            attributes: { foreground: "green" },
            children: ["two"]
          }
        ],
      },
      LineBreak,
      {
        name: "color",
        attributes: { foreground: "red" },
        children: [
          {
            name: "color",
            attributes: { foreground: "green" },
            children: ["line"]
          }
        ],
      },
    ]);
  });
});

describe("processing text output from the game into separate lines", () => {
  test("breaks strings into separate lines", () => {
    let lines = parseText(["new lines \n of text"]);

    expect(lines).toEqual([
      new Line("new lines "),
      new Line(" of text"),
    ]);
  });

  test("more complex version", () => {
    let lines = parseText(["new lines \n of text", [[" extra"], " \ntext"]]);

    expect(lines).toEqual([
      new Line("new lines "),
      new Line([" of text", " extra", " "]),
      new Line("text"),
    ]);
  });

  test("breaks tags into separate lines", () => {
    let lines = parseText([
      {
        name: "color",
        attributes: { foreground: "red"},
        children: [
          "new lines \n of text",
          {
            name: "color",
            attributes: { foreground: "green" },
            children: ["separate\ncolor"]
          },
          "back to red"
        ]
      }
    ]);

    expect(lines).toEqual([
      new Line({
        name: "color",
        attributes: { foreground: "red" },
        children: ["new lines "]
      }),
      new Line({
        name: "color",
        attributes: { foreground: "red" },
        children: [
          " of text",
          {
            name: "color",
            attributes: { foreground: "green" },
            children: ["separate"]
          },
        ],
      }),
      new Line({
        name: "color",
        attributes: { foreground: "red" },
        children: [
          {
            name: "color",
            attributes: { foreground: "green" },
            children: ["color"],
          },
          "back to red",
        ],
      }),
    ]);
  });
});
