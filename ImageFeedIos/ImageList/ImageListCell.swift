import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var imagePhotoView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
            super.prepareForReuse()
            imagePhotoView.kf.cancelDownloadTask()
            imagePhotoView.image = nil
        }
    @IBAction private func likeButtonDidTap() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked (_ isLiked: Bool) {
        let likeImageName = isLiked ? "LikeButtonOn" : "LikeButtonOff"
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}
