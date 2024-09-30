@testable import ImageFeedIos
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    
    func testNumberOfRowsInSection() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        else {
            preconditionFailure("Can't create an instance of ImagesListViewController")
        }
        let presenterSpy = ImagesListPresenterSpy()
        imagesListViewController.presenter = presenterSpy
        presenterSpy.view = imagesListViewController
        
        let numberOfRows = imagesListViewController.tableView(UITableView(), numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfRows, 10, "Count of rows is equal to 10")
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false
        var fetchNextPhotosCalled = false
        
        func viewDidLoad() {
            viewDidLoadCalled = true
            fetchNextPhotos()
        }
        
        func fetchNextPhotos() {
            fetchNextPhotosCalled = true
        }
    
    func getCountOfImages() -> Int {
        return 10
    }
    
    func getLargeImageURL(row: Int) -> String {
        return ""
    }
    
    func getSizeOfImage(row: Int) -> CGSize {
        return .zero
    }
    
    func getImageId(row: Int) -> String {
        return ""
    }
    
    func isImageLiked(row: Int) -> Bool {
        return false
    }
    
    func getThumbnailImageURL(row: Int) -> String {
        return ""
    }
    
    func getImageCreatedAt(row: Int) -> Date? {
        return nil
    }
}

