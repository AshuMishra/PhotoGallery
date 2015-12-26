//
//  Photo.swift
//  PhotoGallery
//
//  Created by Susmita Horrow on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import Foundation
import SwiftyJSON

class Photo {
	var height: Float
	var width: Float
	var reference: String
	init(info: JSON) {
		height = info["height"].floatValue
		width = info["width"].floatValue
		reference = info["photo_reference"].stringValue
	}
}