import Cocoa

protocol Component {
  var collectionView: NSCollectionView { get }
  var view: NSView { get }
}
