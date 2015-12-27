//
//  RequestRouter.swift
//  PhotoGallery
//
//  Created by Ashutosh Mishra on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

enum RequestRouter: URLRequestConvertible {
	private static let apiKey = "AIzaSyAs1tk8BpcNyDqMd3stybMXEyuika1G90c"
	private static let baseURL = "https://maps.googleapis.com/maps/api/place"
	private static let placeSearchURL = "/nearbysearch/json"
	private static let photoFetchURL = "/photo"

	//MARK: API Endpoints
	case fetchNearby(String)
	case fetchPhoto(String)

	//MARK: Endpoint dependent
	private var headers: [String: String] {
		switch self {
		case .fetchPhoto:
			return ["Content-Type": "image/png"]
		default:
			return ["Content-Type": "application/json"]
		}
	}

	private var baseUrl: String {
		switch(self){
		default:
			return RequestRouter.baseURL
		}
	}

	private var method: Alamofire.Method {
		return .GET
	}

	private var path: String {
		switch self {
		case .fetchNearby:
			return "/nearbysearch/json"
		case .fetchPhoto:
			return "/photo"
		}
	}

	private var parameters: [String: String]? {
		switch self {
		case .fetchNearby(let searchParam):
			let coordinateString = String(format: "%f,%f", LocationHandler.sharedInstance.currentUserLocation.coordinate.latitude,
				LocationHandler.sharedInstance.currentUserLocation.coordinate.longitude)
			return ["key": RequestRouter.apiKey, "radius": String(50000), "location": coordinateString, "senser": "true", "types": searchParam]
		case .fetchPhoto(let photoReference):
			return ["key": RequestRouter.apiKey, "photoreference": photoReference, "maxwidth": String(400)]
		}
	}

	private var body: [String: AnyObject]? {
		return nil
	}

	//MARK:
	var URLRequest: NSMutableURLRequest {
		let URL = NSURL(string: baseUrl)!

		let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
		mutableURLRequest.HTTPMethod = method.rawValue
		for (headerField, headerValue) in headers {
			mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
		}

		if let body = body {
			do {
				let jsonData = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.PrettyPrinted)
				mutableURLRequest.HTTPBody = jsonData
				mutableURLRequest.cachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
			}
			catch {
				debugPrint("Error while creating URL Request \(error)")
			}
		}

		let (request, error) = Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableURLRequest, parameters: parameters)
		if let error = error {
			debugPrint("Error while creating URL Request \(error)")
		}
		return request
	}
}


