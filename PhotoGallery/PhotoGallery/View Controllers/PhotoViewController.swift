//
//  PhotoViewController
//  PhotoGallery
//
//  Created by Ashutosh Mishra on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

	@IBOutlet weak var photoGalleryColletionView: UICollectionView!
	var searchArray = [Place]()
	var images = [String: UIImage]()
	let imageCache = NSCache()

	override func viewDidLoad() {
		super.viewDidLoad()
		LocationHandler.sharedInstance.fetchLocation { (location, error) -> () in
			print("location = \(location)")
			print("(\(LocationHandler.sharedInstance.currentUserLocation.coordinate.latitude),\(LocationHandler.sharedInstance.currentUserLocation.coordinate.longitude))")
			if error != nil {
				let alert: UIAlertView = UIAlertView(title: "Location Service Disabled",
					message: "To enable, please go to Settings and turn on Location Service for this app.",
					delegate: nil, cancelButtonTitle: "Not Now", otherButtonTitles: "Enable")

				alert.show()
			} else {
				Place.fetchNearbyPlaces("bar") { [weak self](places, error) -> Void in
					if let places = places {
						guard let weakSelf = self else {
							return
						}
						weakSelf.searchArray = places
						for place in places {
							if let photos = place.photos where photos.count > 0 {
								let photo = photos[0] as Photo
								Place.fetchPhotos(photo.reference, completion: { (photo, error) -> Void in
									weakSelf.images[place.placeId] = photo
									self!.imageCache.setObject(photo!, forKey:weakSelf.images[place.placeId]!)
									weakSelf.photoGalleryColletionView.reloadData()
								})
							}
						}
					}
				}

			}

		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		let destinationVC = segue.destinationViewController as! PreviewViewController
		let indexPath = photoGalleryColletionView.indexPathsForSelectedItems()?.first
		if let indexPath = indexPath {
			let place = searchArray[indexPath.row]
			if let photo = images[place.placeId] {
				destinationVC.image = photo
			}
		}
	}
}

	//MARK: Data source  methods of UICollectionView
	extension PhotoViewController : UICollectionViewDataSource {
		func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
			return 1
		}

		func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return searchArray.count
		}

		func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
			let reuseIdentifier = "cellIdentifier"
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomFlickerCell

			if (searchArray.count > 0) {
				let place = searchArray[indexPath.row] as Place
			  	cell.placeNameLabel.text = place.name
				cell.flickerImageview.image = images[place.placeId]
			}


			// Configure the cell
			return cell
		}
	}

	//MARK: delegate methods of UICollectionView
	extension PhotoViewController : UICollectionViewDelegateFlowLayout {
		func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
			let intercellDistance: Int = 10
			let inset: Int = 10
			let numberOfCellPerRow: Int = 2
			let width = Int(UIScreen.mainScreen().bounds.size.width) - (intercellDistance * (numberOfCellPerRow-1) + inset * 2)
			return CGSizeMake(CGFloat(width / numberOfCellPerRow), CGFloat(width / numberOfCellPerRow))
		}

		func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
			return UIEdgeInsetsMake(10,10, 0,10)
		}
	}

//	extension PhotoViewController : UICollectionViewDelegate {
//
//		func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//
//			var footer =  self.flickerCollectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: flickerFooterViewIdentifier, forIndexPath: indexPath)
//			return footer
//		}
//
//		func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//			let attributes = self.flickerCollectionView.layoutAttributesForItemAtIndexPath(indexPath)
//			let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CustomFlickerCell
//			if (cell.isExpanded == false) {
//				UIView.animateWithDuration(1.0, animations: { () -> Void in
//					let verticalScale = (CGRectGetHeight(UIScreen.mainScreen().bounds)+CGFloat(44.0))/(CGRectGetHeight(cell.frame))
//					let horizontalScale = (CGRectGetWidth(UIScreen.mainScreen().bounds) )/(CGRectGetWidth(cell.frame))
//
//					cell.transform = CGAffineTransformMakeScale(horizontalScale,verticalScale)
//					cell.center = CGPointMake(CGRectGetWidth(UIScreen.mainScreen().bounds)/2,CGRectGetHeight(UIScreen.mainScreen().bounds)/2+self.flickerCollectionView.contentOffset.y);
//					self.flickerCollectionView.bringSubviewToFront(cell)
//
//					}, completion:{ finished in
//						cell.isExpanded = true
//				})
//			}else {
//				UIView.animateWithDuration(1.0, animations: { () -> Void in
//					cell.transform = CGAffineTransformIdentity
//					cell.center = attributes!.center
//
//					}, completion: { finished in
//						cell.isExpanded = false
//				})
//			}
//		}
//	}
//	class CollectionViewLoadingCell: UICollectionReusableView {
//		let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
//
//		required init?(coder aDecoder: NSCoder) {
//			super.init(coder: aDecoder)
//		}
//
//		override init(frame: CGRect) {
//			super.init(frame: frame)
//			
//			spinner.startAnimating()
//			spinner.center = self.center
//			addSubview(spinner)
//		}
//	}
//}

