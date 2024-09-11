import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var imagePhotoView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
            super.prepareForReuse()
            imagePhotoView.kf.cancelDownloadTask()
            imagePhotoView.image = nil
        }
    @IBAction func likeButtonDidTap(_ sender: Any) {
        
    }
}
