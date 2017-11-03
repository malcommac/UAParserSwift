//
//  ViewController.swift
//  TestApplication
//
//  Created by danielemargutti on 01/11/2017.
//  Copyright © 2017 UAParserSwift. All rights reserved.
//

import UIKit
import UAParserSwift

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let str = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
		//let str = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/532.0 (KHTML, like Gecko) Comodo_Dragon/1.0.0.9 Chrome/ Version/3.2.1 Safari/532.0"
		let p = UAParser(agent: str)
//		let browser = p.browser
//		let cpu = p.cpu
//		let engine = p.engine
//		let device = p.device
		let os = p.os
		print("")
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

