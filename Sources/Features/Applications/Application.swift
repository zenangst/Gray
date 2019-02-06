import Foundation

struct Application: Hashable {
  enum Appearance: String, Hashable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
  }

  let bundleIdentifier: String
  let name: String
  let url: URL
  let preferencesUrl: URL
  let appearance: Appearance
  let restricted: Bool

  init(bundleIdentifier: String, name: String,
       url: URL, preferencesUrl: URL,
       appearance: Appearance, restricted: Bool) {
    self.bundleIdentifier = bundleIdentifier
    self.name = name
    self.url = url
    self.preferencesUrl = preferencesUrl
    self.appearance = appearance
    self.restricted = restricted
  }
}
