//
//  APIInterface.swift
//  PhotoGallery
//
//  Created by Susmita Horrow on 26/12/15.
//  Copyright © 2015 Ashu.com. All rights reserved.
//

import Foundation
import Alamofire
import ReachabilitySwift

public typealias ReachabilityCompletionHandler = (Void) -> Void

class APIInterface {
	static func makeRequest(completion: ReachabilityCompletionHandler) {
		let reachability: Reachability
		do {
			reachability = try Reachability.reachabilityForInternetConnection()
			completion()
		} catch {
			print("Unable to create Reachability")
			return
		}
		reachability.whenUnreachable = { reachability in
			// this is called on a background thread, but UI updates must
			// be on the main thread, like this:
			dispatch_async(dispatch_get_main_queue()) {
				print("Not reachable")
			}
		}
		reachability.whenReachable = { reachability in
			completion()
		}

		do {
			try reachability.startNotifier()
		} catch {
			print("Unable to start notifier")
		}
	}
}