import Foundation

protocol Printable {
    func prnt()
}

extension String: Printable {
    func prnt() { 
        print(self)
    }
}

