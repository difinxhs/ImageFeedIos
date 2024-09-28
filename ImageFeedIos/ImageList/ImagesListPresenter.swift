import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func fetchNextPhotos()
    func getCountOfImages() -> Int
    func getLargeImageURL(row: Int) -> String
    func getSizeOfImage(row: Int) -> CGSize
    func getImageId(row: Int) -> String
    func isImageLiked(row: Int) -> Bool
    func getThumbnailImageURL(row: Int) -> String
    func getImageCreatedAt(row: Int) -> Date?
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    
    func fetchNextPhotos() {
        DispatchQueue.main.async {
            self.imagesListService.fetchPhotosNextPage()
            
            NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                print("[ImagesListPresenter fetchNextPhotos] Next pack of images loaded")
            }
        }
    }

    func getCountOfImages() -> Int {
        imagesListService.photos.count
    }
    
    func getLargeImageURL(row: Int) -> String {
        imagesListService.photos[row].fullImageURL
    }
    
    func getSizeOfImage(row: Int) -> CGSize {
        imagesListService.photos[row].size
    }
    
    func getImageId(row: Int) -> String {
        imagesListService.photos[row].id
    }
    
    func isImageLiked(row: Int) -> Bool {
        imagesListService.photos[row].isLiked
    }
    
    func getThumbnailImageURL(row: Int) -> String {
        imagesListService.photos[row].thumbImageURL
    }
    
    func getImageCreatedAt(row: Int) -> Date? {
        imagesListService.photos[row].createdAt
    }
}
