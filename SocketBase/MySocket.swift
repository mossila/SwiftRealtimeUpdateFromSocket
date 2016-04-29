//
//  MySocket.swift
//  SocketBase
//
//  Created by Sutean Rutjanalard on 4/29/2559 BE.
//  Copyright © 2559 Sutean Rutjanalard. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
class MySocket: NSObject, GCDAsyncSocketDelegate {
	static let sharedInstance = MySocket()
	private var socket: GCDAsyncSocket!
	var isConnect = false
	struct SockAddress {
		var host: String
		var port: UInt16
	}
	var sockAddress: SockAddress!
	let separator: NSData = "\n".dataUsingEncoding(NSUTF8StringEncoding)!
	private let timeout = 10.0
	private let reconnectTime = 1.0
	dynamic var lastMessage: String?
	private override init() {
		super.init()
		socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0))

	}

	func startConnect(host: String, port: UInt) {
		try! socket.connectToHost(host, onPort: UInt16(port))
		sockAddress = SockAddress.init(host: host, port: UInt16(port))

	}
	private func read() {
		socket.readDataToData(separator, withTimeout: 10.0, tag: 0)
	}
	/*do not call this is for private selector */
	func reconnect() {
		print("reconnecting")
		do {
			try socket.connectToHost(sockAddress.host, onPort: sockAddress.port)
		} catch _ {
			print("reconnecting fail.")
		}
	}

	// MARK: - GCDAsyncSocketDelegate

	@objc func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
		read()
	}

	@objc func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
		print(err.localizedDescription)

		RunAfterDelay(reconnectTime) {
			[unowned self] in self.reconnect()
		}

	}

	@objc func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
		if let m = NSString(data: data, encoding: NSUTF8StringEncoding) {
			let msg = m.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
			lastMessage = msg
		}
		read()
	}
}