///|
test "parse '{' '}'" {
  let formatter = Formatter::new()
  assert_true((Ok(formatter.init("{}")) catch { error => Err(error) }) is Ok(_))
  formatter.reset()
  assert_true(
    (Ok(formatter.init("{ }")) catch { error => Err(error) }) is Ok(_),
  )
  formatter.reset()
  assert_true((Ok(formatter.init("{")) catch { error => Err(error) }) is Err(_))
  formatter.reset()
  assert_true((Ok(formatter.init("}")) catch { error => Err(error) }) is Err(_))
  formatter.reset()
  assert_true(
    (Ok(formatter.init("{:0}")) catch { error => Err(error) }) is Ok(_),
  )
  formatter.reset()
  assert_true(
    (Ok(formatter.init("Hello {}!")) catch { error => Err(error) }) is Ok(_),
  )
  formatter.reset()
  assert_true(
    (Ok(formatter.init("{0:-} {0:-}")) catch { error => Err(error) }) is Ok(_),
  )
  formatter.reset()
}

///|
test "parse [[fill]align][width]" {
  let formatter = Formatter::new()
  assert_eq(formatter.parse_field(":->"), {
    ..(Default::default() : FormatField),
    fill: '-',
    align: Some(Right),
  })
  assert_eq(formatter.parse_field(":->10"), {
    ..(Default::default() : FormatField),
    fill: '-',
    align: Some(Right),
    width: 10,
  })
}

///|
test "parse [sign]" {
  let formatter = Formatter::new()
  assert_eq(formatter.parse_field(":+"), {
    ..(Default::default() : FormatField),
    sign: Some('+'),
  })
  assert_eq(formatter.parse_field(":-.0"), {
    ..(Default::default() : FormatField),
    sign: Some('-'),
    precision: Some(0),
  })
}

///|
test "parse [\".\" precision]" {
  let formatter = Formatter::new()
  assert_eq(formatter.parse_field(":.2"), {
    ..(Default::default() : FormatField),
    precision: Some(2),
  })
}

///|
test "parse combined format options without consuming lookahead" {
  let formatter = Formatter::new()
  assert_eq(formatter.parse_field(":🙂>+12.3x"), {
    ..(Default::default() : FormatField),
    fill: '🙂',
    align: Some(Right),
    sign: Some('+'),
    width: 12,
    precision: Some(3),
    type_flag: Some('x'),
  })
}
