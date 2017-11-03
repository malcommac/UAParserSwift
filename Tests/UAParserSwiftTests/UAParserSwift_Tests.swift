//
//  UAParserSwiftTests.swift
//  UAParserSwift
//
//  Created by Daniele Margutti on 01/11/2017.
//  Copyright © 2017 UAParserSwift. All rights reserved.
//

import Foundation
import XCTest
import UAParserSwift

public struct TestItem: Decodable {
	public var desc: String
	public var ua: String
	public var expect: [String: String]
}

class UAParserSwiftTests: XCTestCase {
	
	func loadFile(named: String) -> [TestItem]? {
		guard let filePath = Bundle(for: UAParserSwiftTests.self).path(forResource: named, ofType: "json") else {
			return nil
		}
		do {
			let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath))
			let decoder = JSONDecoder()
			let data = try decoder.decode([TestItem].self, from: jsonData)
			return data
		} catch let err {
			return nil
		}
	}
	
    func test_cpu() {
		guard let tests = loadFile(named: "cpu-test") else {
			XCTFail("No tests found")
			return
		}
		for test in tests {
			let parser = UAParser(agent: test.ua)
			let arch_found = parser.cpu?.identifier?.lowercased()
			let arch_exp = test.expect["architecture"]?.lowercased()
			guard arch_found == arch_exp else {
				XCTFail("Failed to test CPU result. Expected \(arch_exp ?? "?"), found \(arch_found ?? "?")")
				return
			}
		}
    }
	
	func test_engines() {
		guard let tests = loadFile(named: "engines-test") else {
			XCTFail("No tests found")
			return
		}
		for test in tests {
			let parser = UAParser(agent: test.ua)
			let engine_name_found = parser.engine?.name?.lowercased()
			let engine_ver_found = parser.engine?.version?.lowercased()

			let engine_name_exp = test.expect["name"]?.lowercased()
			let engine_ver_exp = test.expect["version"]?.lowercased()

			guard engine_name_found == engine_name_exp, engine_ver_found == engine_ver_exp else {
				XCTFail("Failed to test CPU result. Expected \(engine_name_exp), found \(engine_name_found), Expected version \(engine_ver_exp) - Found \(engine_ver_found)")
				return
			}
			print("")
		}
	}
    
    static var allTests = [
        ("testExample", test_cpu),
    ]
}
