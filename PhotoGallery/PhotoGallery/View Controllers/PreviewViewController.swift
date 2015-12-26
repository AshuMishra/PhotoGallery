//
//  PreviewViewController.swift
//  iAppStreetApp
//
//  Created by Susmita Horrow on 26/12/15.
//  Copyright © 2015 Ashutosh Mishra. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	var image: UIImage?

	@IBOutlet weak var scrollView: UIScrollView!
	override func viewDidLoad() {
		super.viewDidLoad()
		imageView.image = image
	}
}

extension PreviewViewController: UIScrollViewDelegate {
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return imageView
	}
}
