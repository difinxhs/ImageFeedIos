import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var fullImageURL: String?
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image = image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        setScales()
    }
    
    @IBAction func backwardButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonDidTap(_ sender: Any) {
        guard let image = self.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        setScales()
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func loadImage() {
        UIBlockingProgressHUD.show()
        guard let fullImageURL = fullImageURL,
              let fullImageURL = URL(string: fullImageURL)
        else {
            print("[SingleImageViewController viewDidLoad] image is nil")
            return
        }
        
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.image = imageResult.image
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Попробовать ещё раз?",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Не надо", style: .default) { [weak self] _ in
            alert.dismiss(animated: true)
        }
        let reload = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        alert.addAction(action)
        alert.addAction(reload)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setScales() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView){
        guard let image else { return }
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let scale = scrollView.zoomScale
        let left = max((visibleRectSize.width - imageSize.width * scale) / 2, 0)
        let top = max((visibleRectSize.height - imageSize.height * scale) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
    }
}
