//
//  Place+APIAdditions.swift
//  PhotoGallery
//
//  Created by Susmita Horrow on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlamofireImage

public typealias FetchPlaceCompletionHandler = (places: [Place]?, error: APIError?) -> Void
public typealias FetchPhotoCompletionHandler = (image: UIImage?, error: APIError?) -> Void

extension Place {
	static	func fetchNearbyPlaces(query: String, completion: FetchPlaceCompletionHandler) {
		APIInterface.makeRequest() {
			Alamofire.request(RequestRouter.fetchNearby(query)).responseJSON { response -> Void in
				switch response.result {
				case .Success:
					if let resultValue = response.result.value {
						let placeArray = JSON(resultValue)["results"].arrayValue
						let places = placeArray.map{ Place(info: $0) }
						let status = JSON(resultValue)["status"].stringValue
						if status == "OVER_QUERY_LIMIT" {
							let errorMessage = JSON(resultValue)["error_message"].stringValue
							let apiError = APIError(code: 5, message: errorMessage)
							completion(places: nil, error: apiError)
						}else {
							completion(places: places, error: nil)
						}
					}else {
						completion(places: nil, error: nil)
					}

				case .Failure:
					let error = response.result.error
					let apiError = APIError(code: error!.code, message: "Cannot fetch error")
					completion(places: nil, error: apiError)
					debugPrint(response)
				}
			}
		}
	}
	static	func fetchPhotos(query: String, completion: FetchPhotoCompletionHandler) {
		Alamofire.request(RequestRouter.fetchPhoto(query)).responseImage { response -> Void in
			if let image = response.result.value {
				completion(image: image, error:  nil)
			}else {
				let apiError = APIError(code: 5, message: (response.result.error?.localizedDescription)!)
				completion(image: nil, error: apiError)
			}
		}
	}
}