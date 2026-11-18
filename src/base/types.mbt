///|
pub(open) trait Formattable: Show {
  fn format(Self, FormatField?) -> String raise FormatError
}

///|
/// @coverage.skip
impl Formattable with fn format(self, _) {
  self.to_string()
}

///|
#derive(Show)
pub struct Formatter {
  strings : Array[String]
  format_specs : Array[String]
  builder : StringBuilder
}

///|
pub type! FormatError {
  ArgumentNotFound(arg_id~ : String)
  UnmatchedCurlyBrace(Char)
  InvalidFormatField(String)
} derive(Show)

///|
#derive(Show, Eq)
enum Align {
  Left
  Right
  Center
}

///|
/// @coverage.skip
impl Default for Align with fn default() {
  Left
}

///|
/// @coverage.skip
impl @strconv.FromStr for Align with fn from_string(str) {
  match str {
    "<" => Left
    ">" => Right
    "^" => Center
    _ => raise @strconv.StrConvError("invalid syntax")
  }
}

///|
#derive(Show, Eq)
struct FormatField {
  arg_id : Int32?
  fill : Char
  align : Align?
  width : Int32
  precision : Int32?
  sign : Char?
  type_flag : Char?
}

///|
/// @coverage.skip
pub impl Default for FormatField with fn default() {
  {
    arg_id: None,
    fill: ' ',
    align: None,
    width: 0,
    precision: None,
    sign: None,
    type_flag: None,
  }
}
