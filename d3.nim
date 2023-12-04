import std/strutils
import std/sequtils
import std/nre
import std/sugar
import std/tables
import std/enumutils


let file = "d3.txt"

type Entry = object
    val: char
    isNumber = false
    isSymbol = false
    isBlank = false
    isPartNumber = false

type Schematic = seq[seq[Entry]]

var rows = collect:
    for line in file.lines:
        collect:
            for c in line:
                if c == '.':
                    Entry(val: c, isBlank: true)
                elif c.isDigit:
                    Entry(val: c, isNumber: true)
                else:
                    Entry(val: c, isSymbol: true)

proc checkNeighbors(entries: Schematic, x: int, y: int, check: proc (e: Entry): bool): bool = 
    # Above left
    y > 0 and entries[y-1][x].check or
    # Above
    y > 0 and x > 0 and entries[y-1][x-1].check or
    # Above right
    y > 0 and x < entries[0].len - 1 and entries[y-1][x+1].check or
    # Left
    x > 0 and entries[y][x-1].check or
    # Right
    x < entries[0].len - 1 and entries[y][x+1].check or
    # Below left
    y < entries.len - 1 and x > 0 and entries[y+1][x-1].check or
    # Below
    y < entries.len - 1 and entries[y+1][x].check or
    # Below right
    y < entries.len - 1 and x < entries[0].len - 1 and entries[y+1][x+1].check

proc partNumberSum(num: seq[Entry]): int = 
    if num.any(n => n.isPartNumber):
        return num.map(n => n.val).join.parseInt

# Mark entries that are part of a part number
for y, row in rows.mpairs:
    for x, entry in row.mpairs:
        if entry.isNumber:
            entry.isPartNumber = rows.checkNeighbors(x, y, e => e.isSymbol)


var sum = 0
for row in rows:
    var num = newSeq[Entry]()
    for entry in row:
        if entry.isNumber:
            num.add(entry)
        else:
            sum += partNumberSum(num)
            num = newSeq[Entry]()
    # Numbers at the end of the row
    sum += partNumberSum(num)
echo sum

