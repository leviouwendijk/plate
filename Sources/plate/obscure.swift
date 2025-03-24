import Foundation

public func obscure(_ string: String,_ revealed: Int = 4,_ obscurechar: Character = "*") -> String {
    let charcount = string.count

    if charcount <= revealed {
        return string
    } else {
        let prefix = string.prefix(revealed)
        let starcount = charcount - revealed
        return prefix + String(repeating: obscurechar, count: starcount)
    }
}
