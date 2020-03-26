import Foundation

struct Application: Hashable {
  enum Appearance: String, Hashable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
  }

  let bundleIdentifier: String
  let name: String
  let metadata: String
  let url: URL
  let preferencesUrl: URL
  let appearance: Appearance
  let restricted: Bool
  var localizedName: String?
}
