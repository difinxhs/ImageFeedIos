import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var imagesListService = ImagesListService()
    
    private var photos: [Photo] = []
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            print("[ImagesListViewController] Notification received")
            self.updateTableViewAnimated()
        }
        //TODO: сделать комплишн на ошибки в fetchPhotosNextPage. Обработать их тут и если ошибки нет, то использовать updateTableViewAnimated
        updateTableViewAnimated()
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("[ImagesListViewController] Invalid segue destination or sender")
                return
            }
            
            let selectedPhoto = photos[indexPath.row]
            viewController.fullImageURL = selectedPhoto.fullImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        print("[ImagesListViewController] Old count: \(oldCount), New count: \(newCount)")
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

//MARK: ConfigCell
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let placeholderImage = UIImage(named: "placeholderImage")
        
        cell.imagePhotoView.kf.indicatorType = .activity
        cell.imagePhotoView.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: placeholderImage,
            options: nil,
            completionHandler: { result in
                switch result {
                case .success(let value):
                    print("[ImagesListViewController] Image loaded successfully for row \(indexPath.row)")
                case .failure(let error):
                    print("[ImagesListViewController] Error loading image: \(error)")
                }
            }
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        let likeImageName = photo.isLiked ? "LikeButtonOn" : "LikeButtonOff"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }

}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = photos.count
        return index
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            print("[ImagesListViewController] Failed to dequeue ImagesListCell")
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        print("[ImagesListViewController] Configuring cell for row at \(indexPath.row)")
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }

}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            print("[ImagesListViewController] WillDisplay")
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
    
      guard let indexPath = tableView.indexPath(for: cell) else { return }
      let photo = photos[indexPath.row]
     UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                // TODO: Показать ошибку с использованием UIAlertController
            }
        }
    }
}
