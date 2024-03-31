import simplifile
import gleam/io
import gleam/result
import gleam/string
import gleam/int
import gleam/list
import gleam/order

const input_filepath = "./data/input.txt"

// const output_filepath = "./data/output.txt"

const digits_names = [
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "one", "two", "three",
  "four", "five", "six", "seven", "eight", "nine",
]

pub fn main() {
  // compute_day_1()
  compute_day_1_part_2()
}

pub fn compute_day_1_part_2() -> Nil {
  input_filepath
  |> load_line_delimited_data
  |> result.unwrap([])
  |> list.map(first_and_last)
  // let _res = save_as_line_delimited_data(res, output_filepath)
  |> list.filter_map(int.parse)
  |> int.sum
  |> io.debug
  Nil
}

pub fn first_and_last(str: String) -> String {
  let indexed = index_digits(str)
  // io.debug(indexed)
  let sorted_indexed =
    list.sort(indexed, fn(a, b) {
      case a.1 < b.1 {
        True -> order.Lt
        False -> order.Gt
      }
    })
  // io.debug(sorted_indexed)
  let first = result.unwrap(list.first(sorted_indexed), #("", -1))
  let last = result.unwrap(list.last(sorted_indexed), #("", -1))
  first.0 <> last.0
}

pub fn index_digits(str: String) -> List(#(String, Int)) {
  index_digits_loop(str, digits_names, [])
}

fn index_digits_loop(
  str: String,
  digits_left: List(String),
  acc: List(#(String, Int)),
) -> List(#(String, Int)) {
  case digits_left {
    [] -> acc
    [first, ..rest] -> {
      let new_indexes =
        get_all_indexes_of_digit(str, first, string.length(first), 0, [])
      // io.debug("---get all indexes for digit END---")
      // io.debug(new_indexes)
      index_digits_loop(str, rest, list.append(new_indexes, acc))
    }
  }
}

fn get_all_indexes_of_digit(
  str: String,
  digit: String,
  digit_length: Int,
  last_idx: Int,
  acc: List(#(String, Int)),
) -> List(#(String, Int)) {
  // io.debug("---get all indexes for digit START---")
  // io.debug(str)
  // io.debug(digit)
  let split_result = string.split_once(str, digit)
  case split_result {
    Error(_e) -> acc
    Ok(split_tuple) -> {
      let add_num = case acc {
        [] -> 0
        _ -> digit_length
      }
      let idx = string.length(split_tuple.0) + add_num + last_idx
      let name_result = result.unwrap(word_to_numeral(digit), "")
      let new_idx_tuple = #(name_result, idx)
      // io.debug(split_tuple.1)
      get_all_indexes_of_digit(split_tuple.1, digit, digit_length, idx, [
        new_idx_tuple,
        ..acc
      ])
    }
  }
}

pub fn word_to_numeral(word: String) -> Result(String, Nil) {
  case word {
    "zero" | "0" -> Ok("0")
    "one" | "1" -> Ok("1")
    "two" | "2" -> Ok("2")
    "three" | "3" -> Ok("3")
    "four" | "4" -> Ok("4")
    "five" | "5" -> Ok("5")
    "six" | "6" -> Ok("6")
    "seven" | "7" -> Ok("7")
    "eight" | "8" -> Ok("8")
    "nine" | "9" -> Ok("9")
    _ -> Error(Nil)
  }
}

pub fn word_to_int(word: String) -> Int {
  case word {
    "zero" | "0" -> 0
    "one" | "1" -> 1
    "two" | "2" -> 2
    "three" | "3" -> 3
    "four" | "4" -> 4
    "five" | "5" -> 5
    "six" | "6" -> 6
    "seven" | "7" -> 7
    "eight" | "8" -> 8
    "nine" | "9" -> 9
    _ -> -1
  }
}

pub fn compute_day_1() -> Nil {
  input_filepath
  |> load_line_delimited_data
  |> result.unwrap([])
  |> list.map(first_and_last_digit)
  |> list.filter_map(int.parse)
  |> int.sum
  |> io.debug
  Nil
}

pub fn load_line_delimited_data(
  filepath: String,
) -> Result(List(String), simplifile.FileError) {
  simplifile.read(from: filepath)
  |> result.map(string.replace(_, "\r", ""))
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

pub fn first_and_last_digit(str: String) -> String {
  string.to_graphemes(str)
  |> list.filter_map(fn(c) {
    case c {
      "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> Ok(c)
      _ -> Error(c)
    }
  })
  |> fn(digits) {
    let first = result.unwrap(list.first(digits), "")
    let last = result.unwrap(list.last(digits), "")
    first <> last
  }
}
