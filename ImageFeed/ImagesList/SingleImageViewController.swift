//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Semen Davydov on 21.09.2026.
//

import Foundation
import UIKit

final class SingleImageViewController : UIViewController {
    // MARK: Variables
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
                imageView.frame.size = image.size
                
                rescaleAndCenterImageInScrollView(image: image)
            }
        }
    }
    
    // MARK: Outlets
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    // MARK: Actions
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        if let image = image {
            imageView.image = image
            imageView.frame.size = image.size
            
            rescaleAndCenterImageInScrollView(image: image)
        }
        
        
        
        
    }
    
}



extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
