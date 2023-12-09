import std/strutils
import std/sequtils
import std/sugar
import std/tables
import std/oids
import std/sets
import std/hashes


let file = "d3.txt"

type 
    Entry = object
        id: Oid
        val: char
        isGearRatio = false
        neighbors: seq[EntryRef]
    EntryRef = ref Entry
    PartNumber = object
        nums: seq[EntryRef]
        val: int
proc newEntry(c: char): EntryRef = 
    EntryRef(id: genOid(), val: c, neighbors: newSeq[EntryRef]())
proc hash(e: EntryRef): int = e.id.hash
proc newPartNumber(nums: seq[EntryRef]): PartNumber = 
    PartNumber(nums: nums, val: nums.map(n => n.val).join.parseInt)
proc isNumber(e: EntryRef): bool = e.val.isDigit
proc isGear(e: EntryRef): bool = e.val == '*'

type Schematic = seq[seq[EntryRef]]

var rows = collect:
    for line in file.lines:
        collect:
            for c in line:
                newEntry(c)

proc populateNeighbors(entries: var Schematic, x: int, y: int) = 
    var entry = entries[y][x]
    # Above left
    if y > 0:
        entry.neighbors.add(entries[y-1][x])
    # Above
    if y > 0 and x > 0:
        entry.neighbors.add(entries[y-1][x-1])
    # Above right
    if y > 0 and x < entries[0].len - 1:
        entry.neighbors.add(entries[y-1][x+1])
    # Left
    if x > 0:
        entry.neighbors.add(entries[y][x-1])
    # Right
    if x < entries[0].len - 1:
        entry.neighbors.add(entries[y][x+1])
    # Below left
    if y < entries.len - 1 and x > 0:
        entry.neighbors.add(entries[y+1][x-1])
    # Below
    if y < entries.len - 1:
        entry.neighbors.add(entries[y+1][x])
    # Below right
    if y < entries.len - 1 and x < entries[0].len - 1:
        entry.neighbors.add(entries[y+1][x+1])

proc hasGearNeighbor(e: EntryRef): bool = 
    e.neighbors.any(n => n.isGear)
proc hasGearNeighbor(p: PartNumber): bool = 
    p.nums.any(hasGearNeighbor)

# Build neighbors seqs
for y, row in rows.pairs:
    for x, entry in row.pairs:
        rows.populateNeighbors(x, y)


var partNumbers = newSeq[PartNumber]()
for row in rows:
    var num = newSeq[EntryRef]()
    for entry in row:
        if entry.isNumber:
            num.add(entry)
        else:
            if num.len > 0: partNumbers.add(newPartNumber(num))
            num = newSeq[EntryRef]()
    # Numbers at the end of the row
    if num.len > 0: partNumbers.add(newPartNumber(num))

var
  gearMap = initTable[EntryRef, seq[int]]()
for partNum in partNumbers:
    for entry in partNum.nums:
        for n in entry.neighbors:
            if n.isGear:
                gearMap.mgetOrPut(n, newSeq[int]()).add(partNum.val)

var sum = 0
for partNums in gearMap.values:
    let ratios = partNums.toHashSet
    if ratios.len == 2:
        sum += ratios.toSeq.foldl(a * b)

echo sum


