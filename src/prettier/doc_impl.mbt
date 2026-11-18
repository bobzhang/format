///|
pub impl Pretty for Doc with fn prettify(self) {
  self
}

///|
pub impl Pretty for String with fn prettify(self) {
  text(self)
}

///|
pub impl Pretty for @rope.Rope with fn prettify(self) {
  Text(self)
}

///|
pub impl Pretty for Int32 with fn prettify(self) {
  content(self)
}

///|
pub impl Pretty for Bool with fn prettify(self) {
  content(self)
}

///|
pub impl Pretty for Float with fn prettify(self) {
  content(self)
}

///|
pub impl Pretty for Double with fn prettify(self) {
  content(self)
}

///|
pub impl Pretty for Char with fn prettify(self) {
  content(self)
}

///|
pub impl Pretty for Unit with fn prettify(_) {
  text("()")
}

///|
pub impl Pretty for Int64 with fn prettify(self) {
  content(self)
}

///|
pub impl Pretty for UInt64 with fn prettify(self) {
  content(self)
}

///|
pub impl Pretty for UInt32 with fn prettify(self) {
  content(self)
}

///|
pub impl[T : Pretty] Pretty for T? with fn prettify(self) {
  match self {
    Some(x) => surround("Some(", x.prettify(), ")")
    None => text("None")
  }
}

///|
pub impl[T : Pretty] Pretty for Array[T] with prettify(self) {
  surround("[", intersperse(text(","), self.map(fn { x => x.prettify() })), "]")
}

///|
pub impl[T : Pretty] Pretty for FixedArray[T] with prettify(self) {
  surround(
    "[",
    intersperse(text(","), self.iter().map(fn { x => x.prettify() }).collect()),
    "]",
  )
}

///|
pub impl[T : Pretty, E : Pretty + Error] Pretty for Result[T, E] with fn prettify(
  self,
) {
  match self {
    Ok(x) => surround("Ok(", x, ")")
    Err(e) => surround("Err(", e.prettify(), ")")
  }
}

///|
pub impl[A : Pretty, B : Pretty] Pretty for Map[A, B] with prettify(self) {
  let entries = self
    .iter()
    .map(fn {
      (k, v) => group(k.prettify() + text(":") + space() + v.prettify())
    })
  surround(
    "{",
    nest(space() + intersperse(text(",") + space(), entries.collect())) +
    space(),
    "}",
  )
}

///|
pub impl Pretty for Json with prettify(self) {
  match self {
    Null => text("null")
    True => text("true")
    False => text("false")
    Number(n) => n.prettify()
    String(s) => surround("\"", s.prettify(), "\"")
    Array(arr) => arr.prettify()
    Object(obj) => {
      let entries = obj
        .iter()
        .map(fn {
          (k, v) =>
            group(
              surround("\"", k.prettify(), "\"") +
              text(":") +
              space() +
              v.prettify(),
            )
        })
      surround(
        "{",
        nest(space() + intersperse(text(",") + space(), entries.collect())) +
        space(),
        "}",
      )
    }
  }
}

///|
test {
  let json : Json = {
    "name": "John Doe",
    "age": 30,
    "isMarried": true,
    "hobbies": ["reading", "swimming"],
  }
  json.prettify().print(width=60)
  |> inspect!(
    content=
      #|{
      #|  "name": "John Doe",
      #|  "age": 30,
      #|  "isMarried": true,
      #|  "hobbies": ["reading","swimming"]
      #|}
    ,
  )
}

///|
pub impl[T : Pretty] Pretty for @style.StyledArg[T] with fn prettify(self) {
  let (start, end) = self._.0.render_style()
  surround(
    @rope.hidden_string(start),
    self._.1.prettify(),
    @rope.hidden_string(end),
  )
}

///|
test {
  inspect!(
    (@style.fg(@style.Red) |
    group(text("hello") + nest(break_with(", ") + text("world"))))
    .prettify()
    .print(width=12),
    content="\x1b[31mhello, world\x1b[39m",
  )
}
