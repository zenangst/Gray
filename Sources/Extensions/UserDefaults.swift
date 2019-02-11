import Foundation

extension UserDefaults {
  var featureViewControllerMode: ApplicationsFeatureViewController.Mode? {
    get {
      let rawValue = UserDefaults.standard.string(forKey: #function) ?? ""
      return ApplicationsFeatureViewController.Mode.init(rawValue: rawValue)
    }
    set {
      UserDefaults.standard.set(newValue?.rawValue, forKey: #function)
    }
  }
}
