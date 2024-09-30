import XCTest
@testable import ImageFeedIos

class ImagesListViewControllerTests: XCTestCase {
    
    var viewController: ImagesListViewController!
    var presenter: MockImagesListPresenter!
    
    override func setUp() {
        super.setUp()
        viewController = ImagesListViewController()
        presenter = MockImagesListPresenter()
        viewController.presenter = presenter
        _ = viewController.view
    }

    override func tearDown() {
        viewController = nil
        presenter = nil
        super.tearDown()
    }
    
    func testViewDidLoadCallsFetchNextPhotos() {
        // Act
        viewController.viewDidLoad()
        
        // Assert
        XCTAssertTrue(presenter.fetchNextPhotosCalled, "fetchNextPhotos() should be called when viewDidLoad is triggered")
    }
    
    func testNumberOfRowsInSection() {
        // Arrange
        let numberOfImages = 5
        presenter.numberOfImages = numberOfImages
        let tableView = UITableView()
        tableView.dataSource = viewController
        
        // Act
        let rows = viewController.tableView(tableView, numberOfRowsInSection: 0)
        
        // Assert
        XCTAssertEqual(rows, numberOfImages, "The number of rows in the table view should match the number of images returned by the presenter")
    }
}

// MARK: - Mock Classes

class MockImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    var fetchNextPhotosCalled = false
    var numberOfImages = 0
    
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
