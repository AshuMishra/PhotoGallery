//
//  Paginator.swift
//  iAppStreet App
//
//  Created by Ashutosh Mishra on 19/07/15.
//  Copyright (c) 2015 Ashutosh Mishra. All rights reserved.
//

import Foundation
import UIKit
import ReachabilitySwift
import Alamofire
import SwiftyJSON

class Paginator: NSObject {
	var url: URLRequestConvertible
	private var finalResult: [JSON]
	var pageCount = 0
	var nextPageToken: String = ""
	var isCallInProgress: Bool = false
	private var allPagesLoaded: Bool = false
	typealias RequestCompletionBlock = (result: [JSON]?, error: APIError?, allPagesLoaded:Bool) -> ()

	init(requestUrl: URLRequestConvertible) {
		url = requestUrl
		finalResult = [JSON]()
	}

	func reset() {
		pageCount = 0
		finalResult = []
	}

	func shouldLoadNext()-> Bool {
		return !(allPagesLoaded && isCallInProgress)
	}

	func loadFirst(completion:RequestCompletionBlock) {
		reset()
		isCallInProgress = true
		Alamofire.request(self.url).responseJSON(completionHandler: {
			[weak self] response -> Void in
			guard let weakSelf = self else {
				return
			}
			weakSelf.isCallInProgress = false
			let parsedResult = weakSelf.parseResult(response)
			if parsedResult.0 == true {
				completion(result: weakSelf.finalResult, error: nil, allPagesLoaded: weakSelf.allPagesLoaded)
			}else if parsedResult.1 != nil {
				completion(result: nil, error: parsedResult.1, allPagesLoaded: weakSelf.allPagesLoaded)
			}else {
				completion(result: nil, error: nil, allPagesLoaded: weakSelf.allPagesLoaded)
			}
		})
	}

	func parseResult(response: Response<AnyObject, NSError>) -> (Bool, APIError?) {
		switch response.result {
		case .Success:
			if let resultValue = response.result.value {
				let jsonResult = JSON(resultValue)
				finalResult.appendContentsOf(jsonResult["results"].arrayValue)
				nextPageToken = jsonResult["next_page_token"].stringValue
				allPagesLoaded = nextPageToken.isEmpty
				pageCount++
				let status = jsonResult["status"].stringValue
				if status == "OVER_QUERY_LIMIT" {
					let errorMessage = JSON(resultValue)["error_message"].stringValue
					let apiError = APIError(code: 5, message: errorMessage)
					return (false, apiError)
				}else if status == "REQUEST_DENIED" {
					let errorMessage = JSON(resultValue)["error_message"].stringValue
					let apiError = APIError(code: 5, message: errorMessage)
					return (false, apiError)
				}else {
					return (true, nil)
				}
			}else {
				return (false, nil)
			}
		case .Failure:
			let apiError = APIError(code: 5, message: "API Error")
			return (false, apiError)
		}
	}

	func loadNext(completion:RequestCompletionBlock) {
		if isCallInProgress || allPagesLoaded {
			print("All pages loaded...")
			return
		} else {
			isCallInProgress = true
			let nextURLString = String(format: "%@&pagetoken=%@", url.URLRequest.URLString, nextPageToken)
			Alamofire.request(.GET, nextURLString).responseJSON {[weak self] response -> Void in
				guard let weakSelf = self else {
					return
				}
				weakSelf.isCallInProgress = false
				let parsedResult = weakSelf.parseResult(response)
				if parsedResult.0 == true {
					completion(result: weakSelf.finalResult, error: nil, allPagesLoaded: weakSelf.allPagesLoaded)
				}else if parsedResult.1 != nil {
					completion(result: nil, error: parsedResult.1, allPagesLoaded: weakSelf.allPagesLoaded)
				}else {
					completion(result: nil, error: nil, allPagesLoaded: weakSelf.allPagesLoaded)
				}
			}
		}
	}
}
