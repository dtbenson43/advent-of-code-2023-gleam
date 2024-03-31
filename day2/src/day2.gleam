import util
import gleam/io
import gleam/string
import gleam/list
import gleam/result
import gleam/int

const input_filepath = "./data/input.txt"

pub type Pull {
  Pull(red: Int, green: Int, blue: Int)
}

pub type Game {
  Game(number: Int, pulls: List(Pull))
}

const possible_game = Pull(12, 13, 14)

pub fn main() {
  result.unwrap(util.load_line_delimited_data(input_filepath), [])
  |> list.map(parse_games)
  |> list.fold(0, get_result_part2)
  |> io.debug
}

pub fn parse_games(game_string: String) -> Game {
  let replaced =
    string.replace(game_string, ", ", ",")
    |> string.replace("; ", ";")
    |> string.replace(": ", ":")
  case replaced {
    "Game " <> rest -> {
      let split_tuple = result.unwrap(string.split_once(rest, ":"), #("", ""))
      let game_number = result.unwrap(int.parse(split_tuple.0), -1)
      let pulls = parse_pulls(split_tuple.1)
      Game(game_number, pulls)
    }
    _ -> Game(-1, [Pull(-1, -1, -1)])
  }
}

pub fn parse_pulls(pulls: String) -> List(Pull) {
  string.split(pulls, ";")
  |> list.map(parse_pull)
}

pub fn parse_pull(pull: String) -> Pull {
  string.split(pull, ",")
  |> list.fold(Pull(0, 0, 0), parse_color_numbers)
}

pub fn parse_color_numbers(pull: Pull, number_color: String) -> Pull {
  let number_color_tuple =
    result.unwrap(string.split_once(number_color, " "), #("", ""))
  let num = result.unwrap(int.parse(number_color_tuple.0), -1)
  case number_color_tuple.1 {
    "red" -> Pull(num, pull.green, pull.blue)
    "green" -> Pull(pull.red, num, pull.blue)
    "blue" -> Pull(pull.red, pull.green, num)
    _ -> pull
  }
}

pub fn get_result_part1(sum: Int, game: Game) -> Int {
  sum
  + case list.any(game.pulls, game_not_possible) {
    True -> 0
    False -> game.number
  }
}

pub fn game_not_possible(pull: Pull) -> Bool {
  pull.red > possible_game.red
  || pull.green > possible_game.green
  || pull.blue > possible_game.blue
}

pub fn get_result_part2(sum: Int, game: Game) -> Int {
  sum + get_power(game)
}

pub fn get_power(game: Game) -> Int {
  let min_pull = list.fold(game.pulls, Pull(0, 0, 0), get_min_game)
  min_pull.red * min_pull.green * min_pull.blue
}

pub fn get_min_game(min_pull: Pull, curr_pull: Pull) -> Pull {
  let Pull(min_red, min_green, min_blue) = min_pull
  let Pull(curr_red, curr_green, curr_blue) = curr_pull

  let new_red = case curr_red > min_red {
    True -> curr_red
    False -> min_red
  }
  let new_green = case curr_green > min_green {
    True -> curr_green
    False -> min_green
  }
  let new_blue = case curr_blue > min_blue {
    True -> curr_blue
    False -> min_blue
  }

  Pull(new_red, new_green, new_blue)
}
// pub fn parse_game_string(game_string: String) -> Result(Game, String) {
// }

// fn parse_game_string_loop(game_string: String, game: Game) -> Game {
//   case game_string {
//     ""
//   }
// }
