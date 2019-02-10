import Cocoa

protocol ToolbarDelegate: class {
  func toolbar(_ toolbar: Toolbar, didSearchFor string: String)
  func toolbar(_ toolbar: Toolbar, didChangeMode mode: String)
}

class Toolbar: NSToolbar, NSToolbarDelegate, ViewToolbarItemDelegate {
  weak var toolbarDelegate: ToolbarDelegate?
  weak var searchField: SearchField?

  override init(identifier: NSToolbar.Identifier) {
    super.init(identifier: identifier)
    allowsUserCustomization = true
    showsBaselineSeparator = true
    delegate = self
  }

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      NSToolbarItem.Identifier.space,
      NSToolbarItem.Identifier.flexibleSpace,
      ViewToolbarItem.itemIdentifier,
      SearchToolbarItem.itemIdentifier
    ]
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return [
      ViewToolbarItem.itemIdentifier,
      NSToolbarItem.Identifier.flexibleSpace,
      SearchToolbarItem.itemIdentifier,
    ]
  }

  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    switch itemIdentifier {
    case ViewToolbarItem.itemIdentifier:
      let viewToolbarItem = ViewToolbarItem()
      viewToolbarItem.delegate = self
      return viewToolbarItem
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
    toolbarDelegate?.toolbar(self, didSearchFor: label.stringValue)
  }

  // MARK: - ViewToolbarItemDelegate

  func viewToolbarItem(_ toolbarItem: ViewToolbarItem, didChange mode: String) {
    toolbarDelegate?.toolbar(self, didChangeMode: mode)
  }
}
