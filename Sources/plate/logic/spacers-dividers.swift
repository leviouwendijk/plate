import Foundation

func printHashes(len: Int, char: Character = "#", times: Int = 1) {
    var reps = times

    while reps != 0 {
        print(String(repeating: "#", count: len))
        reps -= 1
    }
}
