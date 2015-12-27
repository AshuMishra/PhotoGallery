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
	@IBOutlet weak var placeSearchBar: UISearchBar!
	var searchArray = [Place]()
	var images = [String: UIImage]()
	let imageCache = NSCache()

	override func viewDidLoad() {
		super.viewDidLoad()
		getCurrentLocation()
	}

	private func getNearByPlacesWithImage(placeName: String) {
		Place.fetchNearbyPlaces(placeName) { [weak self](places, error) -> Void in
			if let places = places {
				guard let weakSelf = self else {
					return
				}
				weakSelf.searchArray = places
				weakSelf.getImages()
			}else {
				if error != nil {
					print("\(error?.message)")
				}
			}
		}
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
					self!.imageCache.setObject(photo!, forKey:weakSelf.images[place.placeId]!)
					weakSelf.photoGalleryColletionView.reloadData()
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
				weakSelf.getNearByPlacesWithImage("hospitals")
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

//MARK: SearchBar Delegate Methods:-

extension PhotoViewController : UISearchBarDelegate {
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchArray.removeAll(keepCapacity: true)
		placeSearchBar.resignFirstResponder()
		if let searchText = searchBar.text where searchText.characters.count >= 3 {
			getNearByPlacesWithImage(searchText)
		}
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		self.placeSearchBar.text = ""
		self.placeSearchBar.resignFirstResponder()
	}
}


