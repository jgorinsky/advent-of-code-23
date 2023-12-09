import std/strutils
import std/sequtils
import std/nre
import std/sugar
import std/tables
import std/sets
import std/enumerate



let file = "d5.txt"

type Mapping = object
    srcStart: int
    srcEnd: int
    destStart: int
    destEnd: int
type Mappings = seq[Mapping]
type MappingsRef = ref Mappings
type MappingTable = OrderedTable[system.string, seq[Mapping]]
proc newMap(): Mappings = newSeq[Mapping]()

var maps = {
    "seed": newMap(),
    "soil": newMap(),
    "fertilizer": newMap(),
    "water": newMap(),
    "light": newMap(),
    "temperature": newMap(),
    "humidity": newMap(),
}.toOrderedTable
var seeds: seq[int]

proc findMapping(mappings: Mappings, val: int): int =
    for mapping in mappings:
        if val >= mapping.srcStart and val <= mapping.srcEnd:
            return mapping.destStart + (val - mapping.srcStart)
    return val

proc traverse(seed: int): int = 
    var r = seed    
    for key in maps.keys:
        r = findMapping(maps[key], r)
    return r

var currentMap: string
for i, line in enumerate(file.lines):
    if i == 0:
        seeds = line.split(":")[1]
            .split(" ")
            .filterIt(it.isEmptyOrWhitespace.not)
            .mapIt(it.parseInt)
            .toSeq()
        continue

    if line.isEmptyOrWhitespace:
        continue

    if Letters.contains(line[0]):
        # header
        currentMap = line.split("-")[0]
        continue
    
    let parts = line
        .split(" ")
        .filterIt(it.isEmptyOrWhitespace.not)
        .mapIt(it.parseInt)

    maps[currentMap].add(Mapping(
        destStart: parts[0],
        srcStart: parts[1],
        destEnd: parts[0] + parts[2] - 1 ,
        srcEnd: parts[1] + parts[2] - 1,
    ))

echo seeds.map(traverse).min