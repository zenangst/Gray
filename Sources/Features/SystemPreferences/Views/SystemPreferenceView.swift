import Cocoa
import UserInterface

class SystemPreferenceView: NSCollectionViewItem {
  weak var delegate: ApplicationGridViewDelegate?

  lazy var iconView: NSImageView = .init()
  lazy var titleLabel: NSTextField = .init()
  lazy var subtitleLabel: NSTextField = .init()

  override func loadView() {
    let view = NSView()
    view.wantsLayer = true
    self.view = view
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.layer?.backgroundColor = NSColor.white.cgColor
    view.layer?.borderColor = NSColor.gray.withAlphaComponent(0.25).cgColor
    view.layer?.borderWidth = 1.0
    view.layer?.cornerRadius = 20
    view.layer?.masksToBounds = true

    titleLabel.backgroundColor = .clear
    titleLabel.isBezeled = false
    titleLabel.isEditable = false
    titleLabel.maximumNumberOfLines = 2
    titleLabel.font = NSFont.boldSystemFont(ofSize: 13)

    subtitleLabel.backgroundColor = .clear
    subtitleLabel.isBezeled = false
    subtitleLabel.isEditable = false
    subtitleLabel.maximumNumberOfLines = 1
    subtitleLabel.font = NSFont.boldSystemFont(ofSize: 11)

    view.addSubviews(iconView, titleLabel, subtitleLabel)

    let margin: CGFloat = 18

    NSLayoutConstraint.constrain(
      iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
      iconView.widthAnchor.constraint(equalToConstant: 20),
      iconView.heightAnchor.constraint(equalToConstant: 20),

      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
      titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: 0),

      subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
      subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
      subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin)
    )

    configureAppearance()
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    configureAppearance()
  }

  private func configureAppearance() {
    switch view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
    case .darkAqua?:
      view.layer?.backgroundColor = NSColor(named: "Dark")?.cgColor
      titleLabel.animator().textColor = .white
      subtitleLabel.textColor = .lightGray
    case .aqua?:
      view.layer?.backgroundColor = .white
      titleLabel.textColor = .black
      subtitleLabel.textColor = .darkGray
    default:
      break
    }
  }
}

