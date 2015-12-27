//
//  LocationManager.swift
//  PhotoGallery
//
//  Created by Susmita Horrow on 27/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

typealias LocationFetchCompletionBlock = (CLLocation?,error: NSError?) -> ()

class LocationHandler: NSObject, CLLocationManagerDelegate, UIAlertViewDelegate {

	var currentUserLocation = CLLocation()
	private var locationFetchCompletionBlock : LocationFetchCompletionBlock?
	static let sharedInstance = LocationHandler()

	lazy var locationManager: CLLocationManager = {
		var manager = CLLocationManager()
		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyBest
		manager.distanceFilter = 20.0
		return manager
	}()

	func fetchLocation(completionBlock: LocationFetchCompletionBlock) {
		locationFetchCompletionBlock = completionBlock
		updateLocation()
	}

	func updateLocation() {
		locationManager.requestWhenInUseAuthorization()
		let authorizationDenied: Bool = (CLLocationManager.authorizationStatus().rawValue == CLAuthorizationStatus.Denied.rawValue)
		if (authorizationDenied) {
			let error = NSError(domain: "Error", code: 1, userInfo: ["message": "To enable, please go to Settings and turn on Location Service for this app."])
			if let locationFetchCompletionBlock = locationFetchCompletionBlock {
				locationFetchCompletionBlock(nil, error: error)
			}
		}
		else {
			locationManager.startUpdatingLocation()
		}
	}

	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		manager.stopUpdatingLocation()
		currentUserLocation = locations.last!
		if let locationFetchCompletionBlock = locationFetchCompletionBlock {
			locationFetchCompletionBlock(currentUserLocation,error: nil)
		}
	}

	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		self.locationFetchCompletionBlock!(nil,error: error)
	}
}
