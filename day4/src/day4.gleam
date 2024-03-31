import gleam/io
import gleam/dict
import gleam/list
import gleam/string
import gleam/result
import gleam/pair
import gleam/set
import gleam/int
import gleam/float
import util

const input_data_path = "data/input.txt"

pub type CardDict =
  dict.Dict(String, List(String))

pub type WinnersDict =
  CardDict

pub type PicksDict =
  CardDict

pub type Data {
  Data(winners_and_picks: #(WinnersDict, PicksDict), count: Int)
}

pub fn main() {
  util.load_line_delimited_data(input_data_path)
  |> result.unwrap([])
  |> part2()
  |> io.debug
}

pub fn part1(data: List(String)) -> Int {
  parse_cards(data)
  |> get_result
}

pub fn part2(data: List(String)) -> Int {
  parse_cards(data)
  |> get_result2
}

pub fn fix_spaces(str: String) -> String {
  string.replace(str, "   ", " ")
  |> string.replace("  ", " ")
}

pub fn parse_cards(input: List(String)) -> Data {
  let dicts =
    list.fold(
      input,
      #(dict.new(), dict.new()),
      fn(acc: #(WinnersDict, PicksDict), line: String) -> #(
        WinnersDict,
        PicksDict,
      ) {
        let num_and_rest =
          fix_spaces(line)
          |> string.split_once("Card ")
          |> result.unwrap(#("", ""))
          |> pair.second()
          |> string.split_once(": ")
          |> result.unwrap(#("", ""))

        let num = num_and_rest.0
        let rest = num_and_rest.1

        let winners_and_picks =
          string.split_once(rest, " | ")
          |> result.unwrap(#("", ""))

        let winners = string.split(winners_and_picks.0, " ")
        let picks = string.split(winners_and_picks.1, " ")

        let new_winners = dict.insert(acc.0, num, winners)
        let new_picks = dict.insert(acc.1, num, picks)
        #(new_winners, new_picks)
      },
    )
  let count = list.length(input)
  Data(winners_and_picks: dicts, count: count)
}

pub fn get_result(data: Data) -> Int {
  list.range(1, data.count)
  |> list.fold(0, fn(sum: Int, i: Int) -> Int {
    let winners =
      dict.get(data.winners_and_picks.0, int.to_string(i))
      |> result.unwrap([])
    let picks =
      dict.get(data.winners_and_picks.1, int.to_string(i))
      |> result.unwrap([])
    let matches = set.intersection(set.from_list(winners), set.from_list(picks))
    let matches_count = set.size(matches)
    sum
    + {
      case matches_count {
        1 -> 1
        _ ->
          float.truncate(result.unwrap(
            int.power(2, int.to_float(matches_count - 1)),
            0.0,
          ))
      }
    }
  })
}

pub fn get_result2(data: Data) -> Int {
  list.range(data.count, 1)
  |> list.fold(
    #(0, dict.new()),
    fn(sum_container: #(Int, dict.Dict(String, Int)), i: Int) -> #(
      Int,
      dict.Dict(String, Int),
    ) {
      let sum = sum_container.0
      let memo = sum_container.1
      let winners =
        dict.get(data.winners_and_picks.0, int.to_string(i))
        |> result.unwrap([])
      let picks =
        dict.get(data.winners_and_picks.1, int.to_string(i))
        |> result.unwrap([])
      let matches =
        set.intersection(set.from_list(winners), set.from_list(picks))
      let matches_count = set.size(matches)
      let spot = case matches_count {
        0 -> 1
        _ -> {
          list.range(1, matches_count)
          |> list.fold(1, fn(total: Int, j: Int) -> Int {
            let val =
              dict.get(memo, int.to_string(i + j))
              |> result.unwrap(0)
            total + val
          })
        }
      }
      let new_sum = sum + spot
      let new_memo = dict.insert(memo, int.to_string(i), spot)
      #(new_sum, new_memo)
    },
  )
  |> pair.first()
}
