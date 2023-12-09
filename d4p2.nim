import std/strutils
import std/sequtils
import std/nre
import std/sets
import std/enumerate


let file = "d4.txt"

let cardRe = re"Card\s*(?<card_num>\d+):\s*(?<winning>.+)\|(?<mine>.*)"

proc update(s: var seq[int], i: int, multiplier = 1) = 
    if s.len <= i:
        s.add(1 * multiplier)
    else:
        s[i] += 1 * multiplier

var cards = newSeq[int]()

for i, line in enumerate(file.lines):
    let match = line.match(cardRe)

    let winCount = match.get.captures.toSeq[1..2].mapIt(
        it.get
        .split(" ")
        .filterIt(it.isEmptyOrWhitespace.not)
        .mapIt(it.parseInt).toHashSet
    ).foldl(a.intersection(b)).len

    cards.update(i)
    for j in countup(1, winCount):
        cards.update(i+j, cards[i])

echo cards.foldl(a+b)


