import util
import gleam/io
import gleam/string
import gleam/list
import gleam/result
import gleam/int
import gleam/regex
import gleam/dict
import gleam/set

const input_filepath = "./data/input.txt"

pub type NumberCoord =
  #(String, List(#(Int, Int)))

pub type NumberCoordList =
  List(NumberCoord)

pub type GetWholeNumberResult {
  GetWholeNumberResult(
    data: List(String),
    coords: #(Int, Int),
    num_list: NumberCoordList,
  )
}

pub fn main() {
  let data =
    result.unwrap(util.load_string_data(input_filepath), "")
    |> string.replace("\r\n", "\n")
  let data_graphemes = string.to_graphemes(data)
  let symbols = result.unwrap(find_unique_other_characters(data), [])
  //   let symbol_locations =
  //     get_dict_of_symbol_coordinates(symbols, data)
  let symbol_coordinates =
    get_dict_of_symbol_coordinates(symbols, data_graphemes)

  let number_coordinates = get_number_coords_to_check(data_graphemes)
  // |> io.debug
  // get_number_part1(symbol_coordinates, number_coordinates)
  // |> io.debug

  get_number_part2(symbol_coordinates, number_coordinates)
  |> io.debug
}

pub fn to_coords(x: Int, y: Int) -> String {
  int.to_string(x) <> "," <> int.to_string(y)
}

pub fn get_dict_of_symbol_coordinates(
  symbols: List(String),
  data: List(String),
) -> dict.Dict(String, String) {
  get_dict_of_symbol_coordinates_loop(data, dict.new(), symbols, 1, 1)
}

fn get_dict_of_symbol_coordinates_loop(
  chars: List(String),
  coords: dict.Dict(String, String),
  symbols: List(String),
  x: Int,
  y: Int,
) -> dict.Dict(String, String) {
  case chars {
    [] -> coords
    [current, ..rest] -> {
      let new_coords = case list.contains(symbols, current) {
        False -> coords
        True -> {
          dict.insert(coords, to_coords(x, y), current)
        }
      }
      let new_xy = case current == "\n" {
        True -> #(1, y + 1)
        False -> #(x + 1, y)
      }
      get_dict_of_symbol_coordinates_loop(
        rest,
        new_coords,
        symbols,
        new_xy.0,
        new_xy.1,
      )
    }
  }
}

pub fn is_digit(char: String) -> Bool {
  case char {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

// Helper function to add a character to a list if it's not already present
fn add_unique(acc: List(String), char: String) -> List(String) {
  case list.contains(acc, char) {
    True -> acc
    False -> [char, ..acc]
  }
}

// Main function to find unique characters other than digits, periods, and newlines
pub fn find_unique_other_characters(
  input: String,
) -> Result(List(String), regex.CompileError) {
  let pattern = "[^0-9.\n\r]"
  let options = regex.Options(case_insensitive: False, multi_line: True)
  regex.compile(pattern, options)
  |> result.map(fn(re) {
    regex.scan(with: re, content: input)
    |> list.map(fn(match) { match.content })
    |> list.fold([], add_unique)
  })
}

pub fn get_number_coords_to_check(
  data: List(String),
) -> List(#(String, List(#(Int, Int)))) {
  get_number_coords_to_check_loop(data, #(1, 1), [])
}

pub fn get_number_coords_to_check_loop(
  data: List(String),
  coords: #(Int, Int),
  num_list: NumberCoordList,
) -> NumberCoordList {
  case data {
    [] -> num_list
    [first, ..rest] -> {
      case is_digit(first) {
        True -> {
          let result =
            get_whole_number(data, coords, num_list, [], #(first, []))
          get_number_coords_to_check_loop(
            result.data,
            result.coords,
            result.num_list,
          )
        }
        False -> {
          let new_coords = update_coords(first, coords)
          get_number_coords_to_check_loop(rest, new_coords, num_list)
        }
      }
    }
  }
}

pub fn get_whole_number(
  data: List(String),
  coords: #(Int, Int),
  num_list: NumberCoordList,
  digits: List(String),
  num_coord: NumberCoord,
) -> GetWholeNumberResult {
  case data {
    [] -> GetWholeNumberResult(data, coords, [num_coord, ..num_list])
    [first, ..rest] -> {
      case is_digit(first) {
        False -> {
          GetWholeNumberResult(data, coords, [num_coord, ..num_list])
        }
        True -> {
          let new_digits = list.append(digits, [first])
          let new_coords = update_coords(first, coords)
          let new_num_coord = update_num_coord(num_coord, new_digits, coords)
          get_whole_number(
            rest,
            new_coords,
            num_list,
            new_digits,
            new_num_coord,
          )
        }
      }
    }
  }
}

pub fn update_num_coord(
  num_coord: NumberCoord,
  digits: List(String),
  coords: #(Int, Int),
) -> NumberCoord {
  let x = coords.0
  let y = coords.1
  let a = #(x - 1, y - 1)
  let c = #(x - 1, y)
  let b = #(x - 1, y + 1)
  let d = #(x, y - 1)
  let e = #(x, y + 1)
  let f = #(x + 1, y - 1)
  let g = #(x + 1, y)
  let h = #(x + 1, y + 1)
  let new_coord_list =
    set.from_list(num_coord.1)
    |> set.union(set.from_list([a, b, c, d, e, f, g, h]))
    |> set.to_list()
  #(string.join(digits, ""), new_coord_list)
}

pub fn update_coords(char: String, coords: #(Int, Int)) -> #(Int, Int) {
  case char {
    "\n" -> #(1, coords.1 + 1)
    _ -> #(coords.0 + 1, coords.1)
  }
}

pub fn get_number_part1(
  symbols: dict.Dict(String, String),
  numbers: NumberCoordList,
) -> Int {
  list.fold(numbers, 0, fn(amount: Int, nc: NumberCoord) -> Int {
    case
      list.any(nc.1, fn(coords: #(Int, Int)) -> Bool {
        dict.has_key(symbols, to_coords(coords.0, coords.1))
      })
    {
      True -> {
        let numb = result.unwrap(int.parse(nc.0), 0)
        amount + numb
      }
      False -> amount
    }
  })
}

pub fn get_number_part2(
  symbols: dict.Dict(String, String),
  numbers: NumberCoordList,
) -> Int {
  list.fold(
    numbers,
    dict.new(),
    fn(memo: dict.Dict(String, List(String)), current: NumberCoord) -> dict.Dict(
      String,
      List(String),
    ) {
      let coords_to_check = current.1
      let number_str = current.0
      list.fold(
        coords_to_check,
        memo,
        fn(memo_dict: dict.Dict(String, List(String)), coord: #(Int, Int)) -> dict.Dict(
          String,
          List(String),
        ) {
          let coord_str = to_coords(coord.0, coord.1)
          case dict.has_key(symbols, coord_str) {
            True -> {
              case result.unwrap(dict.get(symbols, coord_str), "") == "*" {
                True -> {
                  let curr_val =
                    result.unwrap(dict.get(memo_dict, coord_str), [])
                  let new_val = [number_str, ..curr_val]
                  dict.insert(memo_dict, coord_str, new_val)
                }
                False -> memo_dict
              }
            }
            False -> memo_dict
          }
        },
      )
    },
  )
  |> dict.to_list()
  |> io.debug
  |> list.fold(0, fn(sum: Int, entry: #(String, List(String))) -> Int {
    let new_sum = case list.length(entry.1) != 2 {
      True -> sum
      False ->
        sum
        + list.fold(entry.1, 1, fn(muls: Int, digits: String) -> Int {
          let res = result.unwrap(int.parse(digits), 0)
          muls * res
        })
    }
    io.debug(
      int.to_string(list.length(entry.1)) <> " " <> int.to_string(new_sum),
    )
    io.debug(entry)
    new_sum
  })
}
