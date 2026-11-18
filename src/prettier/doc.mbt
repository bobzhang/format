// References:
// - https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf
// - https://lindig.github.io/papers/strictly-pretty-2000.pdf
// - https://hexdocs.pm/elixir/Inspect.Algebra.html

///|
#derive(Show)
enum SimplifiedDoc {
  Nil
  Text(@rope.Rope, SimplifiedDoc)
  Line(Int32, SimplifiedDoc)
}

///|
fn SimplifiedDoc::to_string(self : SimplifiedDoc) -> String {
  match self {
    Nil => ""
    Text(s, doc) => s.to_string() + doc.to_string()
    Line(i, d) => "\n" + " ".repeat(i) + d.to_string()
  }
}

///|
pub impl @base.Formattable for Doc with fn format(self, field) {
  simplify(field.or_default().width(), 0, [(0, Flat, Group(self))]).to_string()
}

///|
pub fn Doc::op_add(self : Doc, other : Doc) -> Doc {
  Concat(self, other)
}

///|
fn fits(width : Int32, list : Array[(Int32, Mode, Doc)]) -> Bool {
  if width < 0 {
    return false
  }
  match list {
    [] => true
    [(_, _, Empty), .. rest] => fits(width, [..rest])
    [(_, _, Text(s)), .. rest] => fits(width - s.length(), [..rest])
    [(i, m, Concat(x, y)), .. rest] =>
      fits(width, [(i, m, x), (i, m, y), ..rest])
    [(i, m, Nest(j, x)), .. rest] => fits(width, [(i + j, m, x), ..rest])
    [(i, _, Group(x)), .. rest] => fits(width, [(i, Flat, x), ..rest])
    [(_, Flat, Break(s)), .. rest] => fits(width - s.length(), [..rest])
    [(_, Break, Break(_)), ..] => true
  }
}

///|
fn simplify(
  width : Int32,
  column : Int32,
  array : Array[(Int32, Mode, Doc)],
) -> SimplifiedDoc {
  match array {
    [] => Nil
    [(_, _, Empty), .. rest] => simplify(width, column, [..rest])
    [(_, _, Text(s)), .. rest] =>
      SimplifiedDoc::Text(s, simplify(width, column + s.length(), [..rest]))
    [(i, m, Concat(x, y)), .. rest] =>
      simplify(width, column, [(i, m, x), (i, m, y), ..rest])
    [(i, m, Nest(j, x)), .. rest] =>
      simplify(width, column, [(i + j, m, x), ..rest])
    [(i, _, Group(x)), .. rest] =>
      if fits(width - column, [(i, Flat, x), ..rest]) {
        simplify(width, column, [(i, Flat, x), ..rest])
      } else {
        simplify(width, column, [(i, Break, x), ..rest])
      }
    [(_, Flat, Break(s)), .. rest] =>
      Text(@rope.from_string(s), simplify(width, column + s.length(), [..rest]))
    [(i, Break, Break(_)), .. rest] => Line(i, simplify(width, i, [..rest]))
  }
}

///|
pub fn Doc::print(self : Doc, width~ : Int32 = 50) -> String {
  simplify(width, 0, [(0, Flat, Group(self))]).to_string()
}
