import Foundation

extension Optional {
    func require(file: StaticString = #file, line: UInt = #line) -> Wrapped {
        guard let value = self else {
            fatalError("Required value was nil", file: file, line: line)
        }
        return value
    }
}
