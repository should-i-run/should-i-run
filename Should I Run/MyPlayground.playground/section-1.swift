// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"


var myTupleArray  = [("PITT", 3), ("DBLN", 6), ("FRANCE", 12)]

for departure in myTupleArray {
    
    if departure.1 > 6 {
        println(departure.0)
    }
}

