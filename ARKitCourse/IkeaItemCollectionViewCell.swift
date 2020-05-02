import UIKit

class IkeaItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var itemLabel: UILabel!

    func configure(itemName: String) {
        itemLabel.text = itemName
    }
}
