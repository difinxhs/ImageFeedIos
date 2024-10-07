import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func viewDidLoad()
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var imagesListService = ImagesListService.shared
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    var presenter: ImagesListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presenter == nil {
            presenter = ImagesListPresenter()
            presenter?.view = self
        }
        
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
        updateTableViewAnimated()
        presenter?.fetchNextPhotos()
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
            
            let urlString = presenter?.getLargeImageURL(row: indexPath.row)
            viewController.fullImageURL = urlString
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated() {
        guard let presenter = self.presenter else {
            print("[ImagesListViewController] Presenter doesn't exist")
            return
        }
        
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = presenter.getCountOfImages()
        
        print("[ImagesListViewController] Old count: \(oldCount), New count: \(newCount)")
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

//MARK: ConfigCell
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let presenter = self.presenter else { return }
        
        let placeholderImage = UIImage(named: "placeholderImage")
        
        cell.imagePhotoView.kf.indicatorType = .activity
        cell.imagePhotoView.kf.setImage(
            with: URL(string: presenter.getThumbnailImageURL(row: indexPath.row)),
            placeholder: placeholderImage,
            options: nil,
            completionHandler: { result in
                switch result {
                case .success(_):
                    print("[ImagesListViewController] Image loaded successfully for row \(indexPath.row)")
                case .failure(let error):
                    print("[ImagesListViewController] Error loading image: \(error)")
                }
            }
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        cell.dateLabel.text = dateFormatter.string(from: presenter.getImageCreatedAt(row: indexPath.row) ?? Date())
        
        let likeImageName = presenter.isImageLiked(row: indexPath.row) ? "LikeButtonOn" : "LikeButtonOff"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
    
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getCountOfImages() ?? 0
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
        guard let presenter = self.presenter else { return 0 }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageSize = presenter.getSizeOfImage(row: indexPath.row)
        let scale = imageViewWidth / imageSize.width
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let presenter = self.presenter else { return }
        let totalCount = presenter.getCountOfImages()
        if indexPath.row == totalCount - 2 {
            print("[ImagesListViewController] Loading next page")
            presenter.fetchNextPhotos()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let presenter = self.presenter else { return }
        
        let photoId = presenter.getImageId(row: indexPath.row)
        let isLiked = presenter.isImageLiked(row: indexPath.row)
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photoId, isLike: !isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success:
                self.presenter?.fetchNextPhotos()
                cell.setIsLiked(self.presenter?.isImageLiked(row: indexPath.row) ?? false)
            case .failure(let error):
                print("[ImagesListViewController] imageListCellDidTapLike error: \(error)")
            }
        }
    }
}
