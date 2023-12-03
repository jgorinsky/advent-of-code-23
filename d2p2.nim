import std/strutils
import std/sequtils
import std/nre
import std/sugar
import std/tables
import std/enumutils


let file = "d2.txt"

type Color = enum
    red = "red", blue = "blue", green = "green"
converter toColor(s: string): Color = parseEnum[Color](s)

type ColorCount = Table[Color, int]

type Countable = object of RootObj
    counts: ColorCount

type Pull = object
    color: Color
    count: int

type Set = ref object of Countable
    pulls: seq[Pull]

type Game = ref object of Countable
    id: string
    sets: seq[Set]


let gameRe = re"Game (?<game_num>\d+):\s*(?<sets>.*)"
let setRe = re"(.+?)(?:;|$)\s*"
let pullRe = re"(?<count>\d+) (?<color>\w+)"

proc countPulls(pulls: seq[Pull]): ColorCount =
    var counts = {
        red: 0,
        blue: 0,
        green: 0
    }.toTable
    for pull in pulls:
        counts[pull.color] += pull.count
    return counts

proc countSets(sets: seq[Set]): ColorCount =
    var counts = {
        red: 0,
        blue: 0,
        green: 0
    }.toTable

    for set in sets:
        for color, count in set.counts:
            counts[color] += count

    return counts

proc parsePulls(s: string): seq[Pull] =
    return collect:
        for pull in s.findIter(pullRe):
            Pull(count: pull.captures["count"].parseInt, color: pull.captures["color"])

proc parseSets(s: string): seq[Set] =
    return collect:
        for sett in s.findIter(setRe):
            let pulls = parsePulls(sett.match)
            Set(pulls: pulls, counts: countPulls(pulls))

proc parseGame(s: string): Game =
    let gameMatch = s.match(gameRe)
    let gameNum = gameMatch.get.captures["game_num"]
    let gameDetails = gameMatch.get.captures["sets"]
    let sets = parseSets(gameDetails)
    Game(id: gameNum, sets: sets, counts: countSets(sets))

let games = collect:
    for line in file.lines:
        parseGame(line)


let powers = collect:
    for game in games:
        var min = {
            red: 0,
            blue: 0,
            green: 0
        }.toTable
        for s in game.sets:
            for color in Color.items:
                if s.counts[color] > min[color]:
                    min[color] = s.counts[color]
        min[red] * min[blue] * min[green]

echo powers.foldl(a + b)
