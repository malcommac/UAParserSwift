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
		
//		let x = "\\((bb)(10);"
//		let y = "BlackBerry9300/5.0.0.912 Profile/MIDP-2.1 Configuration/CLDC-1.1 VendorID/378".matchingStrings(regex: x)
//
		let p = UAParser(agent: "Opera/9.80 (iPhone; Opera Mini/7.1.32694/27.1407; U; en) Presto/2.8.119 Version/11.10")
		let x = p.os
		print("")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

