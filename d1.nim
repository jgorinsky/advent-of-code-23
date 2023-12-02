import std/strutils
import std/sequtils
import std/sugar

let file = "d1.txt"
var sum = 0
for line in file.lines:
    let nums = line.filter(c => c in Digits)
    let val = (nums[0] & nums[^1]).parseInt
    sum += val
echo sum