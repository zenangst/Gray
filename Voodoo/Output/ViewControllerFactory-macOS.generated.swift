// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Cocoa

class ViewControllerFactory {

  public func createApplicationGridViewController(layout: NSCollectionViewFlowLayout, iconStore: IconStore) -> ApplicationGridViewController {
    let viewController = ApplicationGridViewController(layout: layout, iconStore: iconStore)
    return viewController
  }
  public func createSystemPreferenceViewController(layout: NSCollectionViewFlowLayout, iconStore: IconStore) -> SystemPreferenceViewController {
    let viewController = SystemPreferenceViewController(layout: layout, iconStore: iconStore)
    return viewController
  }
}

