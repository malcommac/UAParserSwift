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
		let p = UAParser(agent: "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; GTB5; Avant Browser; .NET CLR 1.1.4322; .NET CLR 2.0.50727)")
		let x = p.browser
		print("")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

