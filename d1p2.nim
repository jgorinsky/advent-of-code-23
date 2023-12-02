import std/strutils
import std/sequtils
import std/nre
import std/tables
import std/sugar

let file = "d1.txt"
let mapping = {
    "zero": "0",
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five": "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9",
}.toTable
let r = re("(?=(one|two|three|four|five|six|seven|eight|nine))")

let vals = collect:
    for line in file.lines:
        let nums = line
            .replace(r, (match: RegexMatch) => mapping[match.captures[0]])
            .filter(c => c in Digits)
        (nums[0] & nums[^1]).parseInt

echo vals.foldl(a+b)

