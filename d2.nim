import std/strutils
import std/sequtils
import std/nre
import std/sugar
import std/tables


let file = "d2.txt"

type Color = enum
    red = "red", blue = "blue", green = "green"
converter toColor(s: string): Color = parseEnum[Color](s)

type Countable = object of RootObj
    counts: Table[Color, int]

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

proc countPulls(pulls: seq[Pull]): Table[Color, int] =
    var counts = {
        red: 0,
        blue: 0,
        green: 0
    }.toTable
    for pull in pulls:
        counts[pull.color] += pull.count
    return counts

proc countSets(sets: seq[Set]): Table[Color, int] =
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

let testCount = {
    red: 12,
    blue: 14,
    green: 13
}.toTable

proc isValid(game: Game): bool =
    for sett in game.sets:
        for color, count in sett.counts:
            if testCount[color] < count:
                return false
    return true

let valid = games.filter(isValid).mapIt(it.id.parseInt).foldl(a + b)
echo valid
