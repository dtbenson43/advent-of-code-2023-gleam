import gleam/io
import gleam/result
import gleam/string
import simplifile

pub fn load_string_data(
  filepath: String,
) -> Result(String, simplifile.FileError) {
  simplifile.read(from: filepath)
}

pub fn newline_split(str: String) -> List(String) {
  str
  |> string.replace("\r\n", "\n")
  |> string.split("\n")
}

pub fn load_line_delimited_data(
  filepath: String,
) -> Result(List(String), simplifile.FileError) {
  load_string_data(filepath)
  |> result.map(string.replace(_, "\r\n", "\n"))
  |> result.map(string.split(_, "\n"))
}

pub fn save_as_line_delimited_data(
  data: List(String),
  filepath: String,
) -> Result(Nil, simplifile.FileError) {
  let _result = simplifile.create_file(filepath)
  let result =
    data
    |> string.join("\n")
    |> simplifile.write(filepath, _)
  io.debug(result)
}
