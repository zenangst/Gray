import Cocoa

protocol ViewToolbarItemDelegate: class {
  func viewToolbarItem(_ toolbarItem: ViewToolbarItem, didChange mode: String)
}

class ViewToolbarItem: NSToolbarItem {
  static var itemIdentifier: NSToolbarItem.Identifier = .init("View")

  weak var delegate: ViewToolbarItemDelegate?

  lazy var segmentedControl = NSSegmentedControl.init(images: ApplicationsFeatureViewController.Mode.allCases.compactMap({ $0.image }),
                                                      trackingMode: .selectOne,
                                                      target: self,
                                                      action: #selector(didChangeView(_:)))
  lazy var customView = NSView()

  init() {
    super.init(itemIdentifier: ViewToolbarItem.itemIdentifier)
    view = customView
    view?.addSubview(segmentedControl)
    minSize = .init(width: 80, height: 25)
    maxSize = .init(width: 80, height: 25)
    segmentedControl.setToolTip("Grid", forSegment: 0)
    segmentedControl.setTag(0, forSegment: 0)
    segmentedControl.setToolTip("List", forSegment: 1)
    segmentedControl.setTag(1, forSegment: 1)
    configureSegmentControl()
    setupConstraints()

    NotificationCenter.default.addObserver(self, selector: #selector(configureSegmentControl),
                                           name: NSNotification.Name.init(rawValue: "featureViewControllerMode"), object: nil)
  }

  @objc func configureSegmentControl() {
    if let mode = UserDefaults.standard.featureViewControllerMode {
      switch mode {
      case .grid:
        segmentedControl.selectSegment(withTag: 0)
      case .list:
        segmentedControl.selectSegment(withTag: 1)
      }
    } else {
      segmentedControl.selectSegment(withTag: 0)
    }
  }

  func setupConstraints() {
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
    segmentedControl.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
    segmentedControl.widthAnchor.constraint(equalTo: customView.widthAnchor).isActive = true
    segmentedControl.heightAnchor.constraint(equalToConstant: 25).isActive = true
  }

  @objc func didChangeView(_ segmentControl: NSSegmentedControl) {
    guard let label = segmentedControl.toolTip(forSegment: segmentedControl.indexOfSelectedItem) else {
      return
    }

    delegate?.viewToolbarItem(self, didChange: label)
  }
}
