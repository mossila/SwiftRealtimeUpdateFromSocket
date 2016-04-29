//
//  ViewController.swift
//  SocketBase
//
//  Created by Sutean Rutjanalard on 4/29/2559 BE.
//  Copyright © 2559 Sutean Rutjanalard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	lazy var mySocket: MySocket! = MySocket.sharedInstance
	private var myContext = 0
	@IBOutlet var labels: [UILabel]!
	private var alreadyUpdateUI = false
	private var waitForUpdateUI = false
	private let framePerSecond = 60.0
	private var lastUpdateIndex = 0
	private var maxUpdateIndex: Int = 0
	override func viewDidLoad() {
		super.viewDidLoad()
		mySocket.startConnect("localhost", port: 1234)
		maxUpdateIndex = labels.count
	}
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		setupKVO()
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		teardownKVO()
	}
	private func setupKVO() {
		mySocket?.addObserver(self, forKeyPath: "lastMessage", options: .New, context: &myContext)
	}
	private func teardownKVO() {
		mySocket?.removeObserver(self, forKeyPath: "lastMessage")
	}
	private func update() {
		if alreadyUpdateUI { return }
		labels[lastUpdateIndex].text = mySocket.lastMessage
		lastUpdateIndex = (lastUpdateIndex + 1) % maxUpdateIndex
		alreadyUpdateUI = true
		RunAfterDelay(1.0 / framePerSecond) {
			[unowned self] in self.alreadyUpdateUI = false
		}
	}
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if context == &myContext {
			print("\(mySocket.lastMessage)")
			dispatch_async(dispatch_get_main_queue()) {
				[unowned self] in self.update()
			}
		} else {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
		}
	}
}

