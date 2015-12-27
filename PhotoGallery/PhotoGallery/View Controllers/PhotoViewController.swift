//
//  PhotoViewController
//  PhotoGallery
//
//  Created by Ashutosh Mishra on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyJSON

class PhotoViewController: UIViewController {

	@IBOutlet weak var photoGalleryColletionView: UICollectionView!
	@IBOutlet weak var placeSearchBar: UISearchBar!
	var paginator: Paginator?
	var searchArray = [Place]()
	var images = [String: UIImage]()
	let imageCache = NSCache()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupPaginator()
		getCurrentLocation()
	}

	private func setupPaginator() {
		paginator = Paginator(requestUrl: RequestRouter.fetchNearby("bar"))
	}

	private func getNearByPlacesWithImage(placeName: String) {
		searchArray.removeAll()
		paginator?.loadFirst({ [weak self] (result, error, allPagesLoaded) -> () in
			guard let weakSelf = self else {
				return
			}
			if let result = result {
				for placeInfo in result {
					weakSelf.searchArray.append(Place(info: placeInfo))
				}
				weakSelf.photoGalleryColletionView.reloadData()
			}else {
				print("\(error?.message)")
			}
		})
//		Place.fetchNearbyPlaces(placeName) { [weak self](places, error) -> Void in
//			if let places = places {
//				guard let weakSelf = self else {
//					return
//				}
//				weakSelf.searchArray = places
//				weakSelf.photoGalleryColletionView.reloadData()
////				weakSelf.getImages()
//			}else {
//				if error != nil {
//					print("\(error?.message)")
//				}
//			}
//		}
	}

	private func getImages() {
		for place in searchArray {
			if let photos = place.photos where photos.count > 0 {
				let photo = photos[0] as Photo
				Place.fetchPhotos(photo.reference, completion: {[weak self] (photo, error) -> Void in
					guard let weakSelf = self else {
						return
					}
					weakSelf.images[place.placeId] = photo
					weakSelf.imageCache.setObject(photo!, forKey:weakSelf.images[place.placeId]!)
					if weakSelf.searchArray.count > 0 {
						let index = weakSelf.searchArray.indexOf{$0.placeId == place.placeId}
						if let index = index {
							let indexPath = NSIndexPath(forRow: index, inSection: 0)
							weakSelf.photoGalleryColletionView.reloadItemsAtIndexPaths([indexPath])
						}
					}
					})
			}
		}
	}

	private func getCurrentLocation ()  {
		LocationHandler.sharedInstance.fetchLocation {[weak self] (location, error) -> () in
			guard let weakSelf = self else {
				return
			}
			print("(\(LocationHandler.sharedInstance.currentUserLocation.coordinate.latitude),\(LocationHandler.sharedInstance.currentUserLocation.coordinate.longitude))")
			if error != nil {
				let alertVC = UIAlertController(title: "Location Service Disabled",
					message: "To enable, please go to Settings and turn on Location Service for this app.",
					preferredStyle: UIAlertControllerStyle.Alert)
				weakSelf.presentViewController(alertVC, animated: true, completion: nil)
			}else {
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "ListToPhotoVC" {
			let destinationVC = segue.destinationViewController as! PreviewViewController
			let indexPath = photoGalleryColletionView.indexPathsForSelectedItems()?.first
			if let indexPath = indexPath {
				let cell = photoGalleryColletionView.cellForItemAtIndexPath(indexPath) as! CustomFlickerCell
				if let photo = cell.flickerImageview.image {
					destinationVC.image = photo
				}
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
			if let photos = place.photos where photos.count > 0 {
				let photo = photos[0]
//				cell.flickerImageview.af_setImageWithURL(RequestRouter.fetchPhoto(photo.reference).URLRequest.URL!)
			}
//			cell.flickerImageview.image = images[place.placeId]
		}
		return cell
	}
}

//MARK: delegate methods of UICollectionViewDelegateFlowLayout
extension PhotoViewController : UICollectionViewDelegateFlowLayout {
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let intercellDistance: Int = 10
		let inset: Int = 10
		let numberOfCellPerRow: Int = 2
		let width = Int(UIScreen.mainScreen().bounds.size.width) - (intercellDistance * (numberOfCellPerRow-1) + inset * 2)
		return CGSizeMake(CGFloat(width / numberOfCellPerRow), CGFloat(width / numberOfCellPerRow))
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(10, 10, 0, 10)
	}
}

//MARK: SearchBar Delegate Methods:-

extension PhotoViewController : UISearchBarDelegate {
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchArray.removeAll(keepCapacity: true)
		placeSearchBar.resignFirstResponder()
		self.searchArray.removeAll()
		if let searchText = searchBar.text where searchText.characters.count >= 3 {
			if paginator?.nextPageToken.isEmpty == true {
				getNearByPlacesWithImage(searchText)
			}else {
				paginator?.loadNext({ (result, error, allPagesLoaded) -> () in
					if let result = result {
						for placeInfo in result {
							self.searchArray.append(Place(info: placeInfo))
						}
						self.photoGalleryColletionView.reloadData()
					}
				})
			}
		}
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		self.placeSearchBar.text = ""
		self.placeSearchBar.resignFirstResponder()
	}
}


