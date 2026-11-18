///|
test {
  inspect(
    @base.try_format("{}", [fg(@style.Red).lor(emph(Bold)).lor("Test")]),
    content="\u{1B}[31;1mTest\u{1B}[39m\u{1B}[22m",
  )
  inspect(
    @base.try_format("{}", [
      fg(@style.BrightBlue).lor(emph(Underline)).lor("Test"),
    ]),
    content="\u{1B}[94;4mTest\u{1B}[39m\u{1B}[24m",
  )
}

///|
test {
  inspect(
    @base.try_format("{}", [
      emph(Hidden)
      .lor(emph(Underline))
      .lor(emph(Bold))
      .lor("Multi-emphasis Test"),
    ]),
    content="\u{1B}[8;4;1mMulti-emphasis Test\u{1B}[28m\u{1B}[24m\u{1B}[22m",
  )
}
