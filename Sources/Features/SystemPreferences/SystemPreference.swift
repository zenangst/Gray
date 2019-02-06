import Cocoa

struct SystemPreference: Hashable {
  enum ScriptType: String {
    case appleScript
    case shellScript
  }

  let icon: NSImage
  let name: String
  let bundleIdentifier: String
  let value: Bool
  let type: ScriptType
  let script: String
}
