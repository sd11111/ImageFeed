import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    // MARK: Constants
    static let reuseIdentifier = "ImagesListCell"
}
