//
//  APIError.swift
//  PhotoGallery
//
//  Created by Ashutosh Mishra on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import Foundation

public class APIError: ErrorType {

	private static let defaultCode = 9999
	private static let defaultDomain = "Api Error"
	private static let genericErrorMessage = "An error has occured. Pleas try again."

	var code: Int = APIError.defaultCode
	var domain: String = APIError.defaultDomain
	var message: String = APIError.genericErrorMessage

	init(code: Int = APIError.defaultCode, domain: String = APIError.defaultDomain, message: String = APIError.genericErrorMessage) {
		self.code = code
		self.domain = domain
		self.message = message
	}
}