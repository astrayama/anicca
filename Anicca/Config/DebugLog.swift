import Foundation

/// Console logging that compiles out of Release builds.
func debugLog(_ message: @autoclosure () -> String) {
#if DEBUG
    print(message())
#endif
}
