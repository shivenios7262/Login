import Foundation

enum DeviceInfo {
    static var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        if modelCode == "x86_64" || modelCode == "arm64" {
            if let simulatorID = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                return simulatorID
            }
        }
        return modelCode ?? "Unknown"
    }
}
