import Cocoa

protocol ApplicationListViewDelegate: class {
  func applicationView(_ view: ApplicationListView, didResetApplication currentAppearance: Application.Appearance?)
}

// sourcery: let application = Application
class ApplicationListView: NSCollectionViewItem, CollectionViewItemComponent, AppearanceAware {
  let baseView = OpaqueView()
  weak var delegate: ApplicationListViewDelegate?

  // sourcery: currentAppearance = model.application.appearance
  var currentAppearance: Application.Appearance?

  // sourcery: $RawBinding = "iconStore.loadIcon(for: model.application) { image in view.iconView.image = image }"
  lazy var iconView: NSImageView = .init()
  // sourcery: let title: String = "titleLabel.stringValue = model.application.localizedName ?? model.title"
  lazy var titleLabel: NSTextField = .init()
  // sourcery: let subtitle: String = "subtitleLabel.stringValue = model.subtitle"
  lazy var subtitleLabel: NSTextField = .init()

  private var layoutConstraints = [NSLayoutConstraint]()

  override func loadView() {
    self.view = baseView
    self.view.wantsLayer = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Reset".localized, action: #selector(resetApplication), keyEquivalent: ""))
    view.menu = menu

    let verticalStackView = NSStackView(views: [titleLabel, subtitleLabel])
    verticalStackView.alignment = .leading
    verticalStackView.orientation = .vertical
    verticalStackView.spacing = 0
    let stackView = NSStackView(views: [iconView, verticalStackView])
    stackView.orientation = .horizontal

    titleLabel.isEditable = false
    titleLabel.drawsBackground = false
    titleLabel.isBezeled = false
    titleLabel.font = NSFont.boldSystemFont(ofSize: 13)

    subtitleLabel.isEditable = false
    subtitleLabel.drawsBackground = false
    subtitleLabel.isBezeled = false

    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    view.layer?.cornerRadius = 4

    NSLayoutConstraint.deactivate(layoutConstraints)
    layoutConstraints = [
      stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
      stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
    ]
    NSLayoutConstraint.activate(layoutConstraints)
  }

  override func viewDidLayout() {
    super.viewDidLayout()

    guard let currentAppearance = currentAppearance else { return }
    update(with: currentAppearance)
  }

  @objc func resetApplication() {
    delegate?.applicationView(self, didResetApplication: currentAppearance)
  }
}
