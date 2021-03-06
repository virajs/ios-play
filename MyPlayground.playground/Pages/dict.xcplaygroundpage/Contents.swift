import UIKit
import Foundation


// Dictionaries

let dict = ["Chris": " Garrett", "John": "Papa"]


for (key, value) in dict.enumerate()  {
  // TODO
  print("key = \(key) and value = \(value)")
}


let ordinals = [
  1: "first",
  2: "second",
  3: "third"
]

print(ordinals[1]!)
print(ordinals[2]!)
print(ordinals[3]!)

let namesDict = [
  "John": "Papa",
  "Brian": "Clark",
  "Pam": "Dale"
]

let namesArray: [String] = namesDict.map { (f, l) -> String in
  return "\(f) \(l)"
}

print(namesArray)