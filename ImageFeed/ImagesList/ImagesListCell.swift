import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
        
    // MARK: Constants
    static let reuseIdentifier = "ImagesListCell"
    
    
    // MARK: Methods
    override func prepareForReuse() {
        super.prepareForReuse()

        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    
    weak var delegate: ImagesListCellDelegate?

    @IBAction private func didTapLikeButton(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }

    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked
            ? "like_button_on"
            : "like_button_off"

        likeButton.setImage(
            UIImage(named: imageName),
            for: .normal
        )
    }
}


