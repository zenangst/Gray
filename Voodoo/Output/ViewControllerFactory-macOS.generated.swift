// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Cocoa

class ViewControllerFactory {

  public func createApplicationGridViewController(layout: NSCollectionViewFlowLayout) -> ApplicationGridViewController {
    let viewController = ApplicationGridViewController(layout: layout)
    return viewController
  }
  public func createSystemPreferenceViewController(layout: NSCollectionViewFlowLayout) -> SystemPreferenceViewController {
    let viewController = SystemPreferenceViewController(layout: layout)
    return viewController
  }
}

