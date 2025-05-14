// uses ANSI
import Foundation

enum DebugClass: String {
    case info = "INFO"
    case warn = "WARNING"
    case err = "ERROR"
}

protocol Debuggable {
    func debug(_ debugClass: DebugClass,_ debugModeActive: Bool)
}

extension String: Debuggable {
    func debug(_ debugClass: DebugClass,_ debugModeActive: Bool) {
        if debugModeActive == true {
            switch debugClass {
                case .info:
                    print("[\(debugClass.rawValue)]: \(self)".ansi(.brightBlack))
                case .warn:
                    print("[\(debugClass.rawValue)]: \(self)".ansi(.yellow))
                case .err:
                    print("[\(debugClass.rawValue)]: \(self)".ansi(.red))
            }
        }
    }
}
