//
//  RequestRouter.swift
//  PhotoGallery
//
//  Created by Ashutosh Mishra on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import Foundation
import Alamofire

enum RequestRouter: URLRequestConvertible {
	private static let apiKey = "AIzaSyAs1tk8BpcNyDqMd3stybMXEyuika1G90c"
	private static let baseURL = "https://maps.googleapis.com/maps/api/place"
	private static let placeSearchURL = "/nearbysearch/json"
	private static let photoFetchURL = "photo?"

	//MARK: API Endpoints
	case fetchNearby(String)

	//MARK: Endpoint dependent
	private var headers: [String: String] {
		return  [
			"Content-Type": "application/json",
		]
	}

	private var baseUrl: String {
		switch(self){
		default:
			return RequestRouter.baseURL + RequestRouter.placeSearchURL
		}
	}

	private var method: Alamofire.Method {
		return .GET
	}

	private var parameters: [String: String]? {
		switch self {
		case .fetchNearby:
			return ["key": RequestRouter.apiKey, "radius": String(50000), "location": "37.785834,-122.406417", "senser": "true"]
		}
	}

	private var body: [String: AnyObject]? {
		return nil
	}

	//MARK:
	var URLRequest: NSMutableURLRequest {
		let URL = NSURL(string: baseUrl)!

		let mutableURLRequest = NSMutableURLRequest(URL: URL)
		mutableURLRequest.HTTPMethod = method.rawValue
		for (headerField, headerValue) in headers {
			mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
		}

		if let body = body {
			do {
				let jsonData = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.PrettyPrinted)
				mutableURLRequest.HTTPBody = jsonData
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


