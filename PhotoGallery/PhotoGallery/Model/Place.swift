//
//  Place.swift
//  PhotoGallery
//
//  Created by Ashutosh Mishra on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Place {
	var name: String
	var placeId: String
	var photos: [Photo]?

	init(info: JSON) {
		placeId = info["place_id"].stringValue
		name = info["name"].stringValue
		let photosInfo = info["photos"].arrayValue
		photos = photosInfo.map{Photo(info: $0)}
	}
}