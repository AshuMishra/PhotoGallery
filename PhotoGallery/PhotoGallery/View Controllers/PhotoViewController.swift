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
	private var paginator: Paginator?
	private var searchArray = [Place]()
	private let refreshControl = UIRefreshControl()

	//MARK: View LifeCycle Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		initialSetup()
		getCurrentLocation()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	//MARK: Initial setup methods
	private func initialSetup() {
		let layout = UICollectionViewFlowLayout()
		layout.footerReferenceSize = CGSize(width: self.photoGalleryColletionView!.bounds.size.width, height: 100.0)
		photoGalleryColletionView!.collectionViewLayout = layout
		refreshControl.addTarget(self, action: "handleRefreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
		photoGalleryColletionView.addSubview(refreshControl)
	}

	@objc private func handleRefreshControlAction(refreshControl: UIRefreshControl) {
		if let searchText = placeSearchBar.text where searchText.characters.count >= 3 {
			paginator = Paginator(requestUrl: RequestRouter.fetchNearby(searchText))
			searchArray.removeAll()
			paginator?.loadFirst({ [weak self] (result, error, allPagesLoaded) -> () in
				guard let weakSelf = self else {
					return
				}
				refreshControl.endRefreshing()
				if let result = result {
					weakSelf.reloadCollection(result)
				}
				if let error = error {
					weakSelf.showAlert("Error", messgae: error.message)
				}
				print("Count after Pull to refresh = \(weakSelf.searchArray.count)")
			})
		}
	}

	private func reloadCollection(let result: [JSON]) {
		for placeInfo in result {
			searchArray.append(Place(info: placeInfo))
			photoGalleryColletionView.reloadData()
		}
	}

	private func showAlert(title: String, messgae: String) {
		let alertVC = UIAlertController(title: title,message: messgae, preferredStyle: UIAlertControllerStyle.Alert)
		let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { [weak self] action -> Void in
			guard let weakSelf = self else {
				return
			}
			weakSelf.dismissViewControllerAnimated(true, completion: nil)
		}
		alertVC.addAction(action)
		presentViewController(alertVC, animated: true, completion: nil)
	}

	private func getNearByPlacesWithImage(placeName: String) {
		paginator = Paginator(requestUrl: RequestRouter.fetchNearby(placeName))
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
			}
			if let error = error {
				weakSelf.showAlert("Error", messgae: error.message)
			}
		})
	}

	private func getCurrentLocation ()  {
		LocationHandler.sharedInstance.fetchLocation {[weak self] (location, error) -> () in
			guard let weakSelf = self else {
				return
			}
			print("(Location = \(LocationHandler.sharedInstance.currentUserLocation.coordinate.latitude),\(LocationHandler.sharedInstance.currentUserLocation.coordinate.longitude))")
			if error != nil {
				weakSelf.showAlert("Location Service Disabled", messgae: "To enable, please go to Settings and turn on Location Service for this app.")
			}
		}
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
				cell.flickerImageview.af_setImageWithURL(RequestRouter.fetchPhoto(photo.reference).URLRequest.URL!)
			}
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
		if let searchText = searchBar.text where searchText.characters.count >= 3 {
			getNearByPlacesWithImage(searchText)
		}
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		self.placeSearchBar.text = ""
		self.placeSearchBar.resignFirstResponder()
	}
}

//MARK: ScrollView Delegate Methods:-
extension PhotoViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
		if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
			print("Tring to load next.......")
			paginator?.loadNext({ [weak self]  (result, error, allPagesLoaded) -> () in
				guard let weakSelf = self else {
					return
				}
				if let result = result {
					weakSelf.searchArray.removeAll()
					for placeInfo in result {
						weakSelf.searchArray.append(Place(info: placeInfo))
					}
					print("Count after loading = \(weakSelf.searchArray.count)")
					weakSelf.photoGalleryColletionView.reloadData()
				}
				if let error = error {
					weakSelf.showAlert("Error", messgae: error.message)
				}
			})
		}
	}
}

