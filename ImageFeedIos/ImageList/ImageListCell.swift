import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var imagePhotoView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let reuseIdentifier = "ImagesListCell"
}
