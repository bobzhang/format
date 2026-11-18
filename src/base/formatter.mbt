///|
/// @coverage.skip
pub fn Formatter::new() -> Formatter {
  { builder: StringBuilder::StringBuilder(), strings: [], format_specs: [], }
}

///|
fn Formatter::write_string(self : Formatter, string : String) -> Unit {
  self.builder.write_string(string)
}

///|
pub fn Formatter::init(
  self : Formatter,
  format_string : String,
) -> Unit raise FormatError {
  // TODO: Rewrite in a more functional style
  let temp_builder = StringBuilder::StringBuilder()
  let mut iterating_spec = false
  for c in format_string {
    match c {
      '{' => {
        iterating_spec = true
        self.strings.push(self.builder.to_string())
        self.builder.reset()
      }
      '}' =>
        if iterating_spec {
          self.format_specs.push(temp_builder.to_string())
          temp_builder.reset()
          iterating_spec = false
        } else {
          raise UnmatchedCurlyBrace(c)
        }
      _ =>
        if iterating_spec {
          temp_builder.write_char(c)
        } else {
          self.builder.write_char(c)
        }
    }
  }
  if iterating_spec {
    raise UnmatchedCurlyBrace('{')
  }
  if not(self.builder.is_empty()) {
    let string = self.builder.to_string()
    self.strings.push(string)
    self.builder.reset()
  }
}

///|
fn Formatter::reset(self : Formatter) -> Unit {
  self.builder.reset()
  self.strings.clear()
  self.format_specs.clear()
}

///|
/// A format field follows the syntax
/// `{[arg_id][:[[fill]align][sign][width][.precision][type]]}`, where:
///  - `arg_id` : Index of the argument to format
///  - `fill` : Character to use for padding (default: ' ')
///  - `align` : Alignment specifier (`<` for left, `>` for right, `^`
/// for center)
///  - `sign` : Sign specifier (`+` to show plus for positive numbers,
/// and `-` to show minus for negative numbers)
///  - `width` : Minimum field width
///  - `precision` : Precision of decimal
///  - `type` : Type specifier (e.g., 'x' for hexadecimal, 'e' for
/// scientific notation)
fn Formatter::parse_field(
  self : Formatter,
  field : String,
) -> FormatField raise FormatError {
  self |> ignore
  if field.is_blank() {
    raise InvalidFormatField(field)
  }
  fn parse_spec(spec : String) -> FormatField raise FormatError {
    // Iter is consuming in current core. Keep an explicit cursor for lookahead.
    let chars = spec.to_array()
    let mut pos = 0
    let mut field : FormatField = Default::default()
    if chars.get(0) is Some('<' | '>' | '^' as align) {
      field = { ..field, align: Some(Align::from_string(align.to_string())), }
      pos = 1
    } else if chars.get(1) is Some('<' | '>' | '^' as align) {
      field = {
        ..field,
        fill: chars[0],
        align: Some(Align::from_string(align.to_string())),
      }
      pos = 2
    }
    if chars.get(pos) is Some('+' | '-' as sign) {
      field = { ..field, sign: Some(sign), }
      pos += 1
    }
    let width_start = pos
    while chars.get(pos) is Some('0'..<='9') {
      pos += 1
    }
    if pos > width_start {
      let width = @string.parse_int(
        String::from_array(chars[width_start:pos].to_owned()),
      ) catch {
        _ => raise InvalidFormatField(spec)
      }
      field = { ..field, width, }
    }
    if chars.get(pos) is Some('.') {
      pos += 1
      let precision_start = pos
      while chars.get(pos) is Some('0'..<='9') {
        pos += 1
      }
      let precision = @string.parse_int(
        String::from_array(chars[precision_start:pos].to_owned()),
      ) catch {
        _ => raise InvalidFormatField(spec)
      }
      field = { ..field, precision: Some(precision), }
    }
    if chars.get(pos) is Some(flag) {
      field = { ..field, type_flag: Some(flag), }
    }
    field
  }

  match field.find(":").unwrap_or(-1) {
    -1 =>
      if field.is_empty() {
        (Default::default() : FormatField)
      } else {
        guard (Ok(@string.parse_int(field)) catch { error => Err(error) })
          is Ok(arg_id) else {
          raise InvalidFormatField(field)
        }
        { ..(Default::default() : FormatField), arg_id: Some(arg_id), }
      }
    i => {
      let arg_id = match field.substring(end=i) {
        "" => None
        str => {
          guard (Ok(@string.parse_int(str)) catch { error => Err(error) })
            is Ok(arg_id) else {
            raise InvalidFormatField(field)
          }
          Some(arg_id)
        }
      }
      let spec = field.substring(start=i + 1)
      { ..parse_spec(spec), arg_id, }
    }
  }
}

///|
pub fn Formatter::format(
  self : Formatter,
  args : Array[&Formattable],
) -> String raise FormatError {
  for i, fmt in self.format_specs {
    match self.strings.length() >= 1 {
      true => self.write_string(self.strings.remove(0))
      false => ()
    }
    if fmt.is_empty() {
      guard args.get(i) is Some(obj) else {
        raise ArgumentNotFound(arg_id=i.to_string())
      }
      self.write_string(obj.format(None))
    } else {
      let field = self.parse_field(fmt)
      guard args.get(field.arg_id.unwrap_or(i)) is Some(obj) else {
        raise ArgumentNotFound(arg_id=i.to_string())
      }
      self.write_string(obj.format(Some(field)))
    }
  }
  if not(self.strings.is_empty()) {
    self.builder.write_string(self.strings.remove(0))
  }
  self.collect()
}

///|
fn Formatter::collect(self : Formatter) -> String {
  let string = self.builder.to_string()
  self.builder.reset()
  string
}
