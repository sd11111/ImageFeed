import Foundation
import UIKit
import Kingfisher

final class SingleImageViewController : UIViewController {
    
    // MARK: Public Variables
    var fullImageURL: URL?
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }

            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: Private variables
    
    private let minimumZoomScale: Double = 0.1
    private let maximumZoomScale: Double = 1.25
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale

        loadImage()
    }
    
    // MARK: Private Outlets
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: Private Actions
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: Private Func
    private func loadImage() {
        guard let fullImageURL else {
            return
        }

        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: fullImageURL) {
            [weak self] result in

            UIBlockingProgressHUD.dismiss()

            guard let self else {
                return
            }

            switch result {
            case .success(let imageResult):
                self.image = imageResult.image

            case .failure:
                self.showError()
            }
        }
    }

    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так.",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Не надо",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Повторить",
                style: .default
            ) { [weak self] _ in
                self?.loadImage()
            }
        )

        present(alert, animated: true)
    }
    private func rescaleAndCenterImageInScrollView(image: UIImage) {

        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
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
    
}



extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
