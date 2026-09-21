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
    var image: UIImage?
    
    // MARK: Outlets
    @IBOutlet var imageView: UIImageView!
    
    // MARK: Actions
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
