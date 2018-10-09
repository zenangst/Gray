import Cocoa

protocol ToolbarSearchDelegate: class {
  func toolbar(_ toolbar: Toolbar, didSearchFor string: String)
}

class Toolbar: NSToolbar, NSToolbarDelegate {
  weak var searchDelegate: ToolbarSearchDelegate?
  weak var searchField: SearchField?

  override init(identifier: NSToolbar.Identifier) {
    super.init(identifier: identifier)
    allowsUserCustomization = true
    showsBaselineSeparator = false
    delegate = self
  }

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      NSToolbarItem.Identifier.space,
      NSToolbarItem.Identifier.flexibleSpace,
      SearchToolbarItem.itemIdentifier
    ]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      NSToolbarItem.Identifier.space,
      NSToolbarItem.Identifier.flexibleSpace,
      SearchToolbarItem.itemIdentifier
    ]
  }

  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    switch itemIdentifier {
    case SearchToolbarItem.itemIdentifier:
      let searchToolbarItem = SearchToolbarItem(text: "")
      searchToolbarItem.titleLabel.target = self
      searchToolbarItem.titleLabel.action = #selector(search(_:))
      searchField = searchToolbarItem.titleLabel
      return searchToolbarItem
    case NSToolbarItem.Identifier.flexibleSpace:
      return NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.flexibleSpace)
    default:
      return nil
    }
  }

  @objc func search(_ label: SearchField) {
    searchDelegate?.toolbar(self, didSearchFor: label.stringValue)
  }
}
