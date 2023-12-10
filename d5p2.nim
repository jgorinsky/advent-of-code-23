import std/strutils
import std/sequtils
import std/sugar
import std/tables
import std/enumerate
import threadpool
{.experimental: "parallel".}

let file = "d5.txt"

type Mapping = object
    srcStart: int
    srcEnd: int
    destStart: int
    destEnd: int
type Mappings = seq[Mapping]
type MapTable = OrderedTable[system.string, Mappings]
proc newMap(): Mappings = newSeq[Mapping]()

var seedDef: string
var maps = {
    "seed": newMap(),
    "soil": newMap(),
    "fertilizer": newMap(),
    "water": newMap(),
    "light": newMap(),
    "temperature": newMap(),
    "humidity": newMap(),
}.toOrderedTable

var currentMap: string
for i, line in enumerate(file.lines):
    if i == 0:
        seedDef = line
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

iterator seedIter(rng: (int, int)): int =
    for i in countup(rng[0], rng[0] + rng[1] - 1):
        yield i
            
proc findMapping(mappings: Mappings, val: int): int =
    for mapping in mappings:
        if val >= mapping.srcStart and val <= mapping.srcEnd:
            return mapping.destStart + (val - mapping.srcStart)
    return val


proc traverse(seed: int, maps: MapTable): int = 
    var r = seed
    for key in maps.keys:
        r = findMapping(maps[key], r)
    return r


let seedRanges = collect:
    let vals = seedDef.split(":")[1]
        .split(" ")
        .filterIt(it.isEmptyOrWhitespace.not)
        .mapIt(it.parseInt)
    for i, x in vals:
        if i mod 2 == 0:
            (x, vals[i+1])

proc minForRange(rng: (int, int), maps: MapTable): float =
    var min = 99999999999999999
    for seed in seedIter(rng):
        let r = traverse(seed, maps)
        if r < min:
            min = r
    return float(min)

var min = 99999999999999999
parallel:
    var ch = newSeq[float](seedRanges.len)
    for i, rng in seedRanges:
        ch[i] = spawn minForRange(rng, maps)

echo ch.min