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
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		
		let parser = UAParser(agent: "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7")
	}


}

