///|
#derive(Show, Default)
pub struct Style {
  bg : BgColor?
  fg : FgColor?
  emphasis : Array[Emphasis]
}

///|
pub(open) trait Styled {
  fn style(Self) -> Style = _
}

///|
#derive(Show)
pub(all) struct StyledArg[T]((Style, T))

///|
pub impl Styled for Style with fn style(self) {
  self
}

///|
impl Styled with fn style(_) {
  { bg: None, fg: None, emphasis: [], }
}

///|
pub impl[T] Styled for StyledArg[T] with fn style(self) {
  self.0.0
}

///|
#derive(Show, Eq, Arbitrary)
pub(all) enum Color16 {
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  White
  BrightBlack
  BrightRed
  BrightGreen
  BrightYellow
  BrightBlue
  BrightMagenta
  BrightCyan
  BrightWhite
}

///|
#derive(Show, Eq)
pub(all) enum Color {
  Color16(Color16)
  Color256(Int32)
  TrueColor(Int32, Int32, Int32)
}

///|
#derive(Show)
pub(all) struct FgColor(Color)

///|
#derive(Show)
pub(all) struct BgColor(Color)

///|
#derive(Show, Eq)
pub(all) enum Emphasis {
  Bold
  Faint
  Italic
  Underline
  Blink
  Inverse
  Hidden
  Strikethrough
}

///|
pub fn[T : ToColor] fg(color : T) -> Style {
  { bg: None, fg: Some(FgColor(color.to_color())), emphasis: [], }
}

///|
pub fn[T : ToColor] bg(color : T) -> Style {
  { bg: Some(BgColor(color.to_color())), fg: None, emphasis: [], }
}

///|
pub fn emph(emphasis : Emphasis) -> Style {
  { bg: None, fg: None, emphasis: [emphasis], }
}

///|
pub trait ToColor {
  fn to_color(Self) -> Color
}

///|
pub impl Styled for String

///|
pub impl Styled for Double

///|
pub impl Styled for Int32

///|
pub impl Styled for UInt32

///|
pub impl Styled for Int64

///|
pub impl Styled for UInt64

///|
pub impl Styled for Float

///|
pub impl Styled for BigInt
