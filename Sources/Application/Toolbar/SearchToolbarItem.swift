import Cocoa

class SearchToolbarItem: NSToolbarItem, NSSearchFieldDelegate {
    static var itemIdentifier: NSToolbarItem.Identifier = .init("Search")

  lazy var titleLabel = SearchField()
  lazy var customView = NSView()

  init(text: String) {
    super.init(itemIdentifier: SearchToolbarItem.itemIdentifier)
    titleLabel.sizeToFit()
    titleLabel.delegate = self
    customView.frame = titleLabel.frame
    customView.addSubview(titleLabel)
    view = customView
    minSize = .init(width: 175, height: 25)
    maxSize = .init(width: 175, height: 25)
    setupConstraints()
  }

  func setupConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
    titleLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
    titleLabel.widthAnchor.constraint(equalTo: customView.widthAnchor).isActive = true
    titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
  }

  func controlTextDidChange(_ obj: Notification) {
    _ = titleLabel.target?.perform(titleLabel.action, with: titleLabel)
  }
}
