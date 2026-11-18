///|
#derive(Show, Debug, Eq, Default)
pub(all) enum Doc {
  Empty
  Break(String)
  Text(@rope.Rope)
  Concat(Doc, Doc)
  Group(Doc)
  Nest(Int32, Doc)
}

///|
#derive(Show, Eq)
pub enum Mode {
  Flat
  Break
}

///|
pub(open) trait Pretty {
  fn prettify(Self) -> Doc
}

///|
pub(open) trait PrettyFormattable: Pretty + @base.Formattable {
  fn pretty_format(Self, @base.FormatField?) -> Doc raise @base.FormatError
}

///|
pub impl @base.Formattable for &PrettyFormattable with fn format(self, f) {
  @base.Formattable::format(self.pretty_format(f), f)
}

///|
/// @alert unsafe "Panic if error occurs"
pub impl Pretty for &PrettyFormattable with fn prettify(self) {
  (Ok(self.pretty_format(None)) catch { error => Err(error) }).unwrap()
}

///|
pub extend Doc with Pretty::{prettify}

///|
extend @style.StyledArg with Pretty::{prettify}

///|
pub impl @style.Styled for &Pretty
