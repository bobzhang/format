///|
pub fn[T : Styled] Style::lor(self : Style, other : T) -> StyledArg[T] {
  let other_style = other.style()
  let new_style = {
    bg: match self.bg {
      Some(color) => Some(color)
      None => other_style.bg
    },
    fg: match self.fg {
      Some(color) => Some(color)
      None => other_style.fg
    },
    emphasis: self.emphasis + other_style.emphasis,
  }
  StyledArg((new_style, other))
}

///|
pub fn[T : Styled] StyledArg::lor(
  self : StyledArg[Style],
  other : T,
) -> StyledArg[T] {
  StyledArg(
    (Styled::style(Styled::style(self).lor(Styled::style(other))), other),
  )
}

///|
test {
  let _ = fg(Red).lor(bg(Blue)).lor(1.23)
  let _ = fg(Red).lor(emph(Bold)).lor("test")
}

///|
pub impl ToColor for Color with fn to_color(self) {
  self
}

///|
pub impl ToColor for Color16 with fn to_color(self) {
  Color16(self)
}

///|
pub impl ToColor for Int32 with fn to_color(self) {
  Color256(self)
}

///|
pub impl ToColor for (Int32, Int32, Int32) with fn to_color(self) {
  TrueColor(self.0, self.1, self.2)
}

///|
test {
  let _ = fg(Red).lor(bg((255, 255, 255))).lor(1.23)
}
