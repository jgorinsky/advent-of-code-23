import std/strutils
import std/sequtils
import std/nre
import std/sugar
import std/tables
import std/sets



let file = "d4.txt"

type Card = object
    winning: seq[int]
    mine: seq[int]


let cardRe = re"Card\s*(?<card_num>\d+):\s*(?<winning>.+)\|(?<mine>.*)"

let scores = collect:
    for line in file.lines:
        let match = line.match(cardRe)
        let winning = match.get.captures["winning"]
            .split(" ")
            .filterIt(it.isEmptyOrWhitespace.not)
            .mapIt(it.parseInt).toHashSet
        let mine = match.get.captures["mine"]
            .split(" ")
            .filterIt(it.isEmptyOrWhitespace.not)
            .mapIt(it.parseInt).toHashSet

        let winners = winning.intersection(mine).toSeq()
        if winners.len > 0:
            winners[1..^1].foldl(a * 2, 1)

echo scores.foldl(a + b)