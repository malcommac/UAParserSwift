//
//	UAParserSwift
//	Lightweight Swift-based User-Agent string parser
//
//	---------------------------------------------------
//	Created by Daniele Margutti
//		web: http://www.danielemargutti.com
//		email: hello@danielemargutti.com
//
//	Copyright © 2017 Daniele Margutti.
//	Dual licensed under GPLv2 & MIT
//
//	This is a port of ua-parser.js library in Swift
//	Original JavaScript Version - Copyright © 2012-2016 Faisal Salman <fyzlman@gmail.com>
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Foundation

/// MARK: - Parser Class

public class UAParser {
	
	/// User agent raw string
	public private(set) var agent: String
	
	/// Initialize with user agent string
	///
	/// - Parameter agent: user agent string
	public init(agent: String) {
		self.agent = agent
	}
	
	/// identified browser
	public lazy var browser: Browser? = {
		return Browser(self.parse(using: Regexes.browsers))
	}()
	
	/// identified CPU
	public lazy var cpu: CPU? = {
		return CPU(self.parse(using: Regexes.cpu))
	}()
	
	/// identified device
	public lazy var device: Device? = {
		return Device(self.parse(using: Regexes.device))
	}()

	/// identified browser engine
	public lazy var engine: Engine? = {
		return Engine(self.parse(using: Regexes.engine))
	}()

	/// identified operating system
	public lazy var os: OS? = {
		return OS(self.parse(using: Regexes.os))
	}()

	/// Execute parsing based upon passed regular expressions
	///
	/// - Parameter rules: rules to validate, the first one which pass validate the set
	/// - Returns: return found sets
	private func parse(using rules: [Rule]) -> ResultDictionary? {
		for rule in rules {
			for regex in rule.regexp {
				guard let matches = self.agent.matchingStrings(regex: regex) else { continue }
				return self.map(results: matches, to: rule.funcs)
			}
		}
		return nil
	}
	
	/// Execute mapping functions for given regula expression into the array of matched strings
	///
	/// - Parameters:
	///   - results: matched strings array
	///   - functions: functions to execute
	/// - Returns: parsed data array
	private func map(results: [String], to functions: [Funcs]) -> ResultDictionary? {
		var data : ResultDictionary = [:]
		functions.enumerated().forEach { (idx,function) in
			let element: String? = (idx < results.count ? results[idx] : nil)
			switch function {
			case .r(let key):
				if element?.count ?? 0 > 0 {
					data[key] = element!.trimmingCharacters(in: .whitespacesAndNewlines)
				}
			case .rf(let key, let value):
				data[key] = value
			case .mp(let key, let mapping):
				guard let value = element?.uppercased() else {
					break
				}
				for item in mapping.map {
					for candidate in item.value {
						if value.range(of: candidate, options: .caseInsensitive) != nil {
							data[key] = item.key.trimmingCharacters(in: .whitespacesAndNewlines)
							break
						}
					}
					if data[key] != nil { break }
				}
				if data[key] == nil && element?.count ?? 0 > 0 {
					data[key] = element!
				}
			case .rp(let key, let regexp, let replaceWith):
				let newValue = element!.replace(withRegex: regexp, with: replaceWith)
				if newValue.count > 0 {
					data[key] = newValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
				}
				break
			}
		}
		return (data.count > 0 ? data : nil)
	}
}

// MARK: - Internal Classes

/// Define a single rule to execute
internal struct Rule {
	
	/// Set of regular expressions which can validate the rule
	public private(set) var regexp: [NSRegularExpression]
	
	/// Function to execute to parse given regexp results in a valid dictionary
	public private(set) var funcs: [Funcs]

	/// Initialize a new rule set
	///
	/// - Parameters:
	///   - regexp: regular expressions
	///   - funcs: function to parse matched regular expression substrings
	public init(_ regexp: [String], _ funcs: [Funcs]) {
		self.regexp = regexp.map { (regex) in
			try! NSRegularExpression(pattern: regex, options: [.caseInsensitive])
		}

		self.funcs = funcs
	}
	
}

/// Mapped Dictionary
internal protocol MappedKeys {
	var map: [String:[String]] { get }
}

/// Functions available to parse data
///
/// - r: assign matched substring to given key
/// - rf: assign fixed value to given key
/// - rp: assign matched substring by sanitizing with another regexp
/// - mp: map value to dictionary and assign to key
internal enum Funcs {
	case r(_: Key)
	case rf(_: Key, _: String)
	case rp(_: Key, _: String, _: String)
	case mp(_: Key, _: MappedKeys)
}

/// Available keys
///
/// - model: model of the device
/// - name: name (multiple uses)
/// - vendor: vendor of the device
/// - type: type (multiple uses)
/// - version: version (multiple uses)
/// - arch: architecture of the device
public enum Key {
	case model
	case name
	case vendor
	case type
	case version
	case arch
}

public typealias ResultDictionary = [Key:String]

// MARK: - Public Represented Objects

public protocol ParsableData {
	init?(_ data: ResultDictionary?)
}

/// CPU Architecture
public struct CPU: ParsableData {
	
	/// Architecture identifier
	public private(set) var identifier: String?
	
	public init?(_ data: ResultDictionary?) {
		guard let arch = data?[.arch] else { return nil }
		self.identifier = arch
	}
}

/// Browser Identifier
public struct Browser: ParsableData {
	
	/// Browser name
	public private(set) var name: String?
	
	/// Browser version
	public private(set) var version: String?
	
	public init?(_ data: ResultDictionary?) {
		guard let data = data else { return nil }
		if data[.name] == nil && data[.version] == nil { return nil }
		self.name = data[.name]
		self.version = data[.version]
	}
}

/// Device Identifier
public struct Device: ParsableData {
	
	/// Device vendor
	public private(set) var vendor: String?
	
	/// Device type
	public private(set) var type: String?
	
	/// Device model
	public private(set) var model: String?
	
	public init?(_ data: ResultDictionary?) {
		guard let data = data else { return nil }
		self.vendor = data[.vendor]
		self.type = data[.type]
		self.model = data[.model]
		if self.vendor == nil && self.type == nil && self.model == nil {
			return nil
		}
	}
}

/// Browser Engine
public struct Engine: ParsableData {
	
	/// Browser version
	public private(set) var version: String?
	
	/// Browser name
	public private(set) var name: String?

	public init?(_ data: ResultDictionary?) {
		guard let data = data else { return nil }
		self.version = data[.version]
		self.name = data[.name]
		if self.version == nil && self.name == nil {
			return nil
		}
	}
}

/// Operating Systems
public struct OS: ParsableData {
	
	/// Operating system version
	public private(set) var version: String?
	
	/// Operating system name
	public private(set) var name: String?
	
	public init?(_ data: ResultDictionary?) {
		guard let data = data else { return nil }
		self.version = data[.version]
		self.name = data[.name]
		if self.version == nil && self.name == nil {
			return nil
		}
	}
}

// MARK: All Regular Expressions

internal struct Regexes {
	
	/// Browsers
	static let browsers: [Rule] = [
		Rule([
			"(opera\\smini)\\/([\\w\\.-]+)", // Opera Mini
			"(opera\\s[mobiletab]+).+version\\/([\\w\\.-]+)", // Opera Mobi/Tablet
			"(opera).+version\\/([\\w\\.]+)", // Opera > 9.80
			"(opera)[\\/\\s]+([\\w\\.]+)" // Opera < 9.80
		],[.r(.name),.r(.version)]),
		Rule([
			"(opios)[\\/\\s]+([\\w\\.]+)", // Opera mini on iphone >= 8.0
		], [.rf(.name,"Opera Mini"), .r(.version)]),
		Rule([
			"\\s(opr)\\/([\\w\\.]+)", // Opera Webkit
		], [.rf(.name,"Opera"),.r(.version)]),
		Rule([
			// Mixed
			"(kindle)\\/([\\w\\.]+)", // Kindle
			"(lunascape|maxthon|netfront|jasmine|blazer)[\\/\\s]?([\\w\\.]+)*", // Lunascape/Maxthon/Netfront/Jasmine/Blazer
			// Trident based
			"(avant\\s|iemobile|slim|baidu)(?:browser)?[\\/\\s]?([\\w\\.]*)", // Avant/IEMobile/SlimBrowser/Baidu
			"(?:ms|\\()(ie)\\s([\\w\\.]+)", // Internet Explorer
			// Webkit/KHTML based
			"(rekonq)\\/([\\w\\.]+)*", // Rekonq
			"(chromium|flock|rockmelt|midori|epiphany|silk|skyfire|ovibrowser|bolt|iron|vivaldi|iridium|phantomjs|bowser)\\/([\\w\\.-]+)" // Chromium/Flock/RockMelt/Midori/Epiphany/Silk/Skyfire/Bolt/Iron/Iridium/PhantomJS/Bowser
		], [.r(.name),.r(.version)]),
		Rule([
			"(trident).+rv[:\\s]([\\w\\.]+).+like\\sgecko", // IE11
		], [.rf(.name,"IE"),.r(.version)]),
		Rule([
			"(edge)\\/((\\d+)?[\\w\\.]+)", // Microsoft Edge
		], [.r(.name),.r(.version)]),
		Rule([
			"(yabrowser)\\/([\\w\\.]+)", // Yandex
		], [.rf(.name,"Yandex"),.r(.version)]),
		Rule([
			"(puffin)\\/([\\w\\.]+)", // Puffin
		], [.rf(.name,"Puffin"),.r(.version)]),
		Rule([
			"((?:[\\s\\/])uc?\\s?browser|(?:juc.+)ucweb)[\\/\\s]?([\\w\\.]+)"  // UCBrowser
		], [.rf(.name,"UCBrowser"),.r(.version)]),
		Rule([
			"(comodo_dragon)\\/([\\w\\.]+)", // Comodo Dragon
		], [.rp(.name,"_", " "), .r(.version)]),
		Rule([
			"(micromessenger)\\/([\\w\\.]+)", // WeChat
		], [.rf(.name,"WeChat"),.r(.version)]),
		Rule([
			"(QQ)\\/([\\d\\.]+)", // QQ, aka ShouQ
		], [.r(.name),.r(.version)]),
		Rule([
			"m?(qqbrowser)[\\/\\s]?([\\w\\.]+)", // QQBrowser
		], [.r(.name),.r(.version)]),
		Rule([
			"xiaomi\\/miuibrowser\\/([\\w\\.]+)", // MIUI Browser
		], [.r(.version), .rf(.name,"MIUI Browser")]),
		Rule([
			";fbav\\/([\\w\\.]+);", // Facebook App for iOS & Android
		], [.r(.version), .rf(.name,"Facebook")]),
		Rule([
			"headlesschrome(?:\\/([\\w\\.]+)|\\s)", // Chrome Headless
		], [.r(.version),.rf(.name,"Chrome Headless")]),
		Rule([
			"\\swv\\).+(chrome)\\/([\\w\\.]+)", // Chrome WebView
		], [.rp(.name,"(.+)/","$1 WebView"),.r(.version)]),
		Rule([
			"((?:oculus|samsung)browser)\\/([\\w\\.]+)" // Oculus / Samsung Browser
		], [.rp(.name,"(.+(?:g|us))(.+)/","$1 $2"),.r(.version)]),
		Rule([
			"android.+version\\/([\\w\\.]+)\\s+(?:mobile\\s?safari|safari)*", // Android Browser
		],[.r(.version),.rf(.name,"Android Browser")]),
		Rule([
			"(chrome|omniweb|arora|[tizenoka]{5}\\s?browser)\\/v?([\\w\\.]+)", // Chrome/OmniWeb/Arora/Tizen/Nokia
		],[.r(.name),.r(.version)]),
		Rule([
			"(dolfin)\\/([\\w\\.]+)", // Dolphin
		], [.rf(.name,"Dolphin"),.r(.version)]),
		Rule([
			"((?:android.+)crmo|crios)\\/([\\w\\.]+)", // Chrome for Android/iOS
		],[.rf(.name,"Chrome"),.r(.version)]),
		Rule([
			"(coast)\\/([\\w\\.]+)", // Opera Coast
		],[.rf(.name,"Opera Coast"),.r(.version)]),
		Rule([
			"fxios\\/([\\w\\.-]+)", // Firefox for iOS
		], [.r(.version),.rf(.name,"Firefox")]),
		Rule([
			"version\\/([\\w\\.]+).+?mobile\\/\\w+\\s(safari)", // Mobile Safari
		], [.r(.version),.rf(.name,"Mobile Safari")]),
		Rule([
			"version\\/([\\w\\.]+).+?(mobile\\s?safari|safari)", // Safari & Safari Mobile
		], [.r(.version),.r(.name)]),
		Rule([
			"webkit.+?(gsa)\\/([\\w\\.]+).+?(mobile\\s?safari|safari)(\\/[\\w\\.]+)", // Google Search Appliance on iOS
		], [.rf(.name,"GSA"),.r(.version)]),
		Rule([
			"webkit.+?(mobile\\s?safari|safari)(\\/[\\w\\.]+)", // Safari < 3.0
		], [.r(.name),.mp(.version, OldSafariMap())]),
		Rule([
			"(konqueror)\\/([\\w\\.]+)/i,", // Konqueror
			"(webkit|khtml)\\/([\\w\\.]+)",
		],[.r(.name),.r(.version)]),
		Rule([
			// Gecko based
			"(navigator|netscape)\\/([\\w\\.-]+)", // Netscape
		],[.rf(.name,"Netscape"),.r(.version)]),
		Rule([
			"(swiftfox)", // Swiftfox
			"(icedragon|iceweasel|camino|chimera|fennec|maemo\\sbrowser|minimo|conkeror)[\\/\\s]?([\\w\\.\\+]+)", // IceDragon/Iceweasel/Camino/Chimera/Fennec/Maemo/Minimo/Conkeror
			"(firefox|seamonkey|k-meleon|icecat|iceape|firebird|phoenix)\\/([\\w\\.-]+)", // Firefox/SeaMonkey/K-Meleon/IceCat/IceApe/Firebird/Phoenix
			"(mozilla)\\/([\\w\\.]+).+rv\\:.+gecko\\/\\d+", // Mozilla
			// Other
			"(polaris|lynx|dillo|icab|doris|amaya|w3m|netsurf|sleipnir)[\\/\\s]?([\\w\\.]+)", // Polaris/Lynx/Dillo/iCab/Doris/Amaya/w3m/NetSurf/Sleipnir
			"(links)\\s\\(([\\w\\.]+)", // Links,
			"(gobrowser)\\/?([\\w\\.]+)*", // GoBrowser
			"(ice\\s?browser)\\/v?([\\w\\._]+)", // ICE Browser
			"(mosaic)[\\/\\s]([\\w\\.]+)", // Mosaic
		], [.r(.name),.r(.version)])
	]
	
	/// CPU Architectures
	static let cpu: [Rule] = [
		Rule([
			"(?:(amd|x(?:(?:86|64)[_-])?|wow|win)64)[;\\)]", // AMD64
			], [.rf(.arch,"amd64")]),
		Rule([
			"(ia32(?=;))" // IA32 (quicktime)
		], [.r(.arch)]),
		Rule([
			"((?:i[346]|x)86)[;\\)]" // // IA32
		],[.rf(.arch,"ia32")]),
		Rule([
			"windows\\s(ce|mobile);\\sppc;", // PocketPC mistakenly identified as PowerPC
		],[.rf(.arch,"arm")]),
		Rule([
			"((?:ppc|powerpc)(?:64)?)(?:\\smac|;|\\))", // PowerPC
		],[.rp(.arch,"ower","")]),
		Rule([
			"(sun4\\w)[;\\)]", // SPARC
		],[.rf(.arch,"sparc")]),
		Rule([
			"((?:avr32|ia64(?=;))|68k(?=\\))|arm(?:64|(?=v\\d+;))|(?=atmel\\s)avr|(?:irix|mips|sparc)(?:64)?(?=;)|pa-risc)", // IA64, 68K, ARM/64, AVR/32, IRIX/64, MIPS/64, SPARC/64, PA-RISC
		],[.r(.arch)])
	]
	
	/// Devices
	static let device: [Rule] = [
		Rule([
			"\\((ipad|playbook);[\\w\\s\\);-]+(rim|apple)", // iPad/PlayBook
		],[.r(.model),.r(.vendor),.rf(.type,"tablet")]),
		Rule([
			"applecoremedia\\/[\\w\\.]+ \\((ipad)/", // iPad
		],[.r(.model),.rf(.vendor,"apple"),.rf(.type,"tablet")]),
		Rule([
			"(apple\\s{0,1}tv)", // Apple TV
		],[.rf(.model,"apple tv"),.rf(.vendor,"apple")]),
		Rule([
			"(archos)\\s(gamepad2?)", // Archos
			"(hp).+(touchpad)", // HP TouchPad
			"(hp).+(tablet)", // HP Tablet
			"(kindle)\\/([\\w\\.]+)", // Kindle
			"\\s(nook)[\\w\\s]+build\\/(\\w+)", // Nook
			"(dell)\\s(strea[kpr\\s\\d]*[\\dko])", // Dell Streak
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"(kf[A-z]+)\\sbuild\\/[\\w\\.]+.*silk\\/", // Kindle Fire HD
		],[.r(.model),.rf(.vendor,"amazon"),.rf(.type,"tablet")]),
		Rule([
			"(sd|kf)[0349hijorstuw]+\\sbuild\\/[\\w\\.]+.*silk\\/", // Fire Phone
		],[.mp(.model,AmazonDeviceMap()),.rf(.vendor,"amazon"),.rf(.type,"mobile")]),
		Rule([
			"\\((ip[honed|\\s\\w*]+);.+(apple)", // iPod/iPhone
		],[.r(.model),.r(.vendor),.rf(.type,"mobile")]),
		Rule([
			"\\((ip[honed|\\s\\w*]+);", // iPod/iPhone
		],[.r(.model),.rf(.vendor,"apple"),.rf(.type,"mobile")]),
		Rule([
			"(blackberry)[\\s-]?(\\w+)", // BlackBerry
			"(blackberry|benq|palm(?=\\-)|sonyericsson|acer|asus|dell|meizu|motorola|polytron)[\\s_-]?([\\w-]+)*", // BenQ/Palm/Sony-Ericsson/Acer/Asus/Dell/Meizu/Motorola/Polytron
			"(hp)\\s([\\w\\s]+\\w)", // HP iPAQ
			"(asus)-?(\\w+)", // Asus
		],[.r(.vendor),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"\\(bb10;\\s(\\w+)", // BlackBerry 10
		],[.r(.model),.rf(.vendor,"BlackBerry"),.rf(.type,"mobile")]),
		Rule([
			"android.+(transfo[prime\\s]{4,10}\\s\\w+|eeepc|slider\\s\\w+|nexus 7|padfone)", // Asus Tablets
		],[.r(.model),.rf(.vendor,"asus"),.rf(.type,"tablet")]),
		Rule([
			"(sony)\\s(tablet\\s[ps])\\sbuild\\/", // Sony Xperia
			"(sony)?(?:sgp.+)\\sbuild\\/"
		], [.rf(.vendor,"sony"),.rf(.model,"xperia tablet"),.rf(.type,"tablet")]),
		Rule([
			"android.+\\s([c-g]\\d{4}|so[-l]\\w+)\\sbuild\\/" // Sony
		],[.r(.model),.rf(.vendor,"sony"),.rf(.type,"mobile")]),
		Rule([
			"\\s(ouya)\\s", // Ouya
			"(nintendo)\\s([wids3u]+)", // Nintendo
		],[.r(.vendor),.r(.model),.rf(.type,"console")]),
		Rule([
			"android.+;\\s(shield)\\sbuild", // Nvidia
		], [.r(.model),.rf(.vendor,"sony"),.rf(.type,"console")]),
		Rule([
			"(playstation\\s[34portablevi]+)", // Playstation
		],[.r(.model),.rf(.vendor,"sony"),.rf(.type,"console")]),
		Rule([
			"(sprint\\s(\\w+))", // Sprint Phones
		],[.mp(.vendor,SprintVendorMap()), .mp(.model, SprintModelMap()), .rf(.type,"mobile")]),
		Rule([
			"(lenovo)\\s?(S(?:5000|6000)+(?:[-][\\w+]))", // Lenovo tablets
		], [.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"(htc)[;_\\s-]+([\\w\\s]+(?=\\))|\\w+)*", // HTC
			"(zte)-(\\w+)*", // ZTE,
			"(alcatel|geeksphone|lenovo|nexian|panasonic|(?=;\\s)sony)[_\\s-]?([\\w-]+)*", // Alcatel/GeeksPhone/Lenovo/Nexian/Panasonic/Sony
		], [.r(.vendor),.rp(.model,"_"," "),.rf(.type,"mobile")]),
		Rule([
			"(nexus\\s9)", // HTC Nexus 9
		], [.r(.model),.rf(.vendor,"htc"),.rf(.type,"tablet")]),
		Rule([
			"d\\/huawei([\\w\\s-]+)[;\\)]", // Huawei
			"(nexus\\s6p)"
		],[.r(.model),.rf(.vendor,"huawei"),.rf(.type,"mobile")]),
		Rule([
			"(microsoft);\\s(lumia[\\s\\w]+)", // Microsoft Lumia
		],[.r(.vendor),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"[\\s\\(;](xbox(?:\\sone)?)[\\s\\);]", // Microsoft Xbox
		],[.r(.model),.rf(.vendor,"microsoft"),.rf(.type,"console")]),
		Rule([
			"(kin\\.[onetw]{3})", // Microsoft Kin
		],[.rp(.model,"\\."," "),.rf(.vendor,"microsoft"),.rf(.type,"mobile")]),
		Rule([
			"\\s(milestone|droid(?:[2-4x]|\\s(?:bionic|x2|pro|razr))?(:?\\s4g)?)[\\w\\s]+build\\/", // Motorola
			"mot[\\s-]?(\\w+)*",
			"(XT\\d{3,4}) build\\/",
			"(nexus\\s6)"
		],[.r(.model),.rf(.vendor,"motorola"),.rf(.type,"mobile")]),
		Rule([
			"android.+\\s(mz60\\d|xoom[\\s2]{0,2})\\sbuild\\/", // Motorola
		],[.r(.model),.rf(.vendor,"motorola"),.rf(.type,"tablet")]),
		Rule([
			"hbbtv\\/\\d+\\.\\d+\\.\\d+\\s+\\([\\w\\s]*;\\s*(\\w[^;]*);([^;]*)", // HbbTV devices
		],[.r(.vendor),.r(.model),.rf(.type,"smarttv")]),
		Rule([
			"hbbtv.+maple;(\\d+)",
		],[.rp(.model,"^/","SmartTV"),.rf(.vendor,"samsung"),.rf(.type,"smarttv")]),
		Rule([
			"\\(dtv[\\);].+(aquos)", // Sharp
		],[.r(.model),.rf(.vendor,"sharp"),.rf(.type,"smarttv")]),
		Rule([
			"android.+((sch-i[89]0\\d|shw-m380s|gt-p\\d{4}|gt-n\\d+|sgh-t8[56]9|nexus 10))", // Samsung
			"((SM-T\\w+))"
		],[.rf(.vendor,"samsung"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"smart-tv.+(samsung)",
		],[.r(.vendor),.rf(.type,"smarttv"),.r(.model)]),
		Rule([
			"((s[cgp]h-\\w+|gt-\\w+|galaxy\\snexus|sm-\\w[\\w\\d]+))",
			"(sam[sung]*)[\\s-]*(\\w+-?[\\w-]*)*",
			"sec-((sgh\\w+))"
		],[.rf(.vendor,"samsung"),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"sie-(\\w+)*", // Siemens
		],[.r(.model),.rf(.vendor,"siemes"),.rf(.type,"mobile")]),
		Rule([
			"(maemo|nokia).*(n900|lumia\\s\\d+)", // Nokia
			"(nokia)[\\s_-]?([\\w-]+)*",
		],[.rf(.vendor,"nokia"),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"android\\s3\\.[\\s\\w;-]{10}(a\\d{3})", // Acer
		],[.r(.model),.rf(.vendor,"acer"),.rf(.type,"tablet")]),
		Rule([
			"android.+([vl]k\\-?\\d{3})\\s+build", // LG Tablet
		],[.r(.model),.rf(.vendor,"lg"),.rf(.type,"tablet")]),
		Rule([
			"android\\s3\\.[\\s\\w;-]{10}(lg?)-([06cv9]{3,4})", // LG Tablet
		],[.rf(.vendor,"lg"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"(lg) netcast\\.tv", // LG SmartTV
		],[.r(.vendor),.r(.model),.rf(.type,"smarttv")]),
		Rule([
			"(nexus\\s[45])", // LG
			"lg[e;\\s\\/-]+(\\w+)*",
			"android.+lg(\\-?[\\d\\w]+)\\s+build",
		],[.r(.model),.rf(.vendor,"lg"),.rf(.type,"mobile")]),
		Rule([
			"android.+(ideatab[a-z0-9\\-\\s]+)", // Lenovo
		],[.r(.model),.rf(.vendor,"lenovo"),.rf(.type,"tablet")]),
		Rule([
			"linux;.+((jolla));", // Jolla
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"((pebble))app\\/[\\d\\.]+\\s", // Pebble
		],[.r(.vendor),.r(.model),.rf(.type,"wearable")]),
		Rule([
			"android.+;\\s(oppo)\\s?([\\w\\s]+)\\sbuild", // OPPO
		],[.r(.vendor),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"crkey", // Google Chromecast
		],[.rf(.model,"chromecast"),.rf(.vendor,"google")]),
		Rule([
			"android.+;\\s(glass)\\s\\d", // Google Glass
		],[.r(.model),.rf(.vendor,"google"),.rf(.type,"wearable")]),
		Rule([
			"android.+;\\s(pixel c)\\s", // Google Pixel C
		],[.r(.model),.rf(.vendor,"google"),.rf(.type,"tablet")]),
		Rule([
			"android.+;\\s(pixel xl|pixel)\\s", // Google Pixel
		],[.r(.model),.rf(.vendor,"google"),.rf(.type,"mobile")]),
		Rule([
			"android.+(\\w+)\\s+build\\/hm\\1", // Xiaomi Hongmi 'numeric' models
			"android.+(hm[\\s\\-_]*note?[\\s_]*(?:\\d\\w)?)\\s+build", // Xiaomi Hongmi
			"android.+(mi[\\s\\-_]*(?:one|one[\\s_]plus|note lte)?[\\s_]*(?:\\d\\w)?)\\s+build", // Xiaomi Mi
			"android.+(redmi[\\s\\-_]*(?:note)?(?:[\\s_]*[\\w\\s]+)?)\\s+build", // Redmi Phones
		],[.rp(.model,"_"," "), .rf(.vendor,"xiaomi"),.rf(.type,"mobile")]),
		Rule([
			"android.+(mi[\\s\\-_]*(?:pad)?(?:[\\s_]*[\\w\\s]+)?)\\s+build" // Mi Pad tablets
		],[.rp(.model,"_"," "), .rf(.vendor,"xiaomi"),.rf(.type,"tablet")]),
		Rule([
			"android.+;\\s(m[1-5]\\snote)\\sbuild", // Meizu Tablet
		],[.r(.model),.rf(.vendor,"meizu"),.rf(.type,"tablet")]),
		Rule([
			"android.+a000(1)\\s+build", // OnePlus
		],[.r(.model),.rf(.vendor,"oneplus"),.rf(.type,"mobile")]),
		Rule([
			"android.+[;\\/]\\s*(RCT[\\d\\w]+)\\s+build", // RCA Tablets
		],[.r(.model),.rf(.vendor,"rca"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(Venue[\\d\\s]*)\\s+build" // // Dell Venue Tablets
		],[.r(.model),.rf(.vendor,"dell"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(Q[T|M][\\d\\w]+)\\s+build", // Verizon Tablet
		],[.r(.model),.rf(.vendor,"verizon"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s+(Barnes[&\\s]+Noble\\s+|BN[RT])(V?.*)\\s+build", // Barnes & Noble Tablet
		],[.rf(.vendor,"barnes & noble"), .r(.model),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s+(TM\\d{3}.*\\b)\\s+build", // Barnes & Noble Tablet
		],[.r(.model),.rf(.vendor,"nuvision"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(zte)?.+(k\\d{2})\\s+build", // ZTE K Series Tablet
		],[.rf(.vendor,"zte"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(gen\\d{3})\\s+build.*49h", // Swiss GEN Mobile
		],[.r(.model),.rf(.vendor,"swiss"),.rf(.type,"mobile")]),
		Rule([
			"android.+[;\\/]\\s*(zur\\d{3})\\s+build", // Swiss ZUR Tablet
		],[.r(.model),.rf(.vendor,"swiss"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*((Zeki)?TB.*\\b)\\s+build", // Zeki Tablets
		],[.r(.model),.rf(.vendor,"zeki"),.rf(.type,"tablet")]),
		Rule([
			"(android).+[;\\/]\\s+([YR]\\d{2}x?.*)\\s+build", // Dragon Touch Tablet
			"android.+[;\\/]\\s+(Dragon[\\-\\s]+Touch\\s+|DT)(.+)\\s+build",
		],[.rf(.vendor,"dragon touch"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(NS-?.+)\\s+build", // Insignia Tablets
		],[.r(.model),.rf(.vendor,"insignia"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*((NX|Next)-?.+)\\s+build", // NextBook Tablets
		],[.r(.model),.rf(.vendor,"nextbook"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(Xtreme\\_?)?(V(1[045]|2[015]|30|40|60|7[05]|90))\\s+build", // Voice Xtreme Phones
		],[.rf(.vendor,"voice"),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"android.+[;\\/]\\s*(LVTEL\\-?)?(V1[12])\\s+build", // LvTel Phones
		],[.rf(.vendor,"lvtel"),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"android.+[;\\/]\\s*(V(100MD|700NA|7011|917G).*\\b)\\s+build" // Envizen Tablets
		],[.r(.model),.rf(.vendor,"envizen"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(Le[\\s\\-]+Pan)[\\s\\-]+(.*\\b)\\s+build", // Le Pan Tablets
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(Trio[\\s\\-]*.*)\\s+build", // MachSpeed Tablets
		],[.r(.model),.rf(.vendor,"machspeed"),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*(Trinity)[\\-\\s]*(T\\d{3})\\s+build", // Trinity Tablets
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"android.+[;\\/]\\s*TU_(1491)\\s+build", // Rotor Tablets
		],[.r(.model),.rf(.vendor,"rotor"),.rf(.type,"tablet")]),
		Rule([
			"android.+(KS(.+))\\s+build", // Amazon Kindle Tablets
		],[.r(.model),.rf(.vendor,"amazon"),.rf(.type,"tablet")]),
		Rule([
			"android.+(Gigaset)[\\s\\-]+(Q.+)\\s+build/i]", // Gigaset Tablets
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"\\s(tablet|tab)[;\\/]", // Unidentifiable Tablet
			"\\s(mobile)(?:[;\\/]|\\ssafari)", // Unidentifiable Mobile
		],[.r(.type),.r(.vendor),.r(.model)]),
		Rule([
			"(android.+)[;\\/].+build", // Generic Android Device
		],[.r(.model),.rf(.vendor,"generic")])
	]
	
	/// Browser Engines
	static let engine: [Rule] = [
		Rule([
			"windows.+\\sedge\\/([\\w\\.]+)", // EdgeHTML
		],[.r(.version),.rf(.name,"EdgeHTML")]),
		Rule([
			"(presto)\\/([\\w\\.]+)", // Presto
			"(webkit|trident|netfront|netsurf|amaya|lynx|w3m)\\/([\\w\\.]+)", // WebKit/Trident/NetFront/NetSurf/Amaya/Lynx/w3m
			"(khtml|tasman|links)[\\/\\s]\\(?([\\w\\.]+)", // KHTML/Tasman/Links
			"(icab)[\\/\\s]([23]\\.[\\d\\.]+)" // iCab
		],[.r(.name),.r(.version)]),
		Rule([
			"rv\\:([\\w\\.]+).*(gecko)"	// Gecko
		],[.r(.version),.r(.name)]),
	]
	
	/// Operating Systems
	static let os: [Rule] = [
		Rule([
			// Windows based
			"microsoft\\s(windows)\\s(vista|xp)", // Windows (iTunes)
		],[.r(.name),.r(.version)]),
		Rule([
			"(windows)\\snt\\s6\\.2;\\s(arm)", // Windows RT
			"(windows\\sphone(?:\\sos)*)[\\s\\/]?([\\d\\.\\s]+\\w)*", // Windows Phone
			"(windows\\smobile|windows)[\\s\\/]?([ntce\\d\\.\\s]+\\w)"
		],[.r(.name),.mp(.version,WindowsOSMap())]),
		Rule([
			"(win(?=3|9|n)|win\\s9x\\s)([nt\\d\\.]+)", // Windows
		],[.rf(.name,"windows"),.mp(.version,WindowsOSMap())]),
		Rule([
			// Mobile/Embedded OS
			"\\((bb)(10);" // BlackBerry 10
		],[.rf(.name,"blackberry"),.r(.version)]),
		Rule([
			"(blackberry)\\w*\\/?([\\w\\.]+)*",  // Blackberry
			"(tizen)[\\/\\s]([\\w\\.]+)", // Tizen
			"(android|webos|palm\\sos|qnx|bada|rim\\stablet\\sos|meego|contiki)[\\/\\s-]?([\\w\\.]+)*", // Android/WebOS/Palm/QNX/Bada/RIM/MeeGo/Contiki
			"linux;.+(sailfish);" // Sailfish OS
		],[.r(.name),.r(.version)]),
		Rule([
			"(symbian\\s?os|symbos|s60(?=;))[\\/\\s-]?([\\w\\.]+)*", // Symbian
		],[.rf(.name,"symbian"),.r(.version)]),
		Rule([
			"\\((series40);", // Series 40
		],[.r(.name)]),
		Rule([
			"mozilla.+\\(mobile;.+gecko.+firefox", // Firefox OS
		],[.rf(.name,"firefox os"),.r(.version)]),
		Rule([
			// Console
			"(nintendo|playstation)\\s([wids34portablevu]+)", // Nintendo/Playstation
			// GNU/Linux based
			"(mint)[\\/\\s\\(]?(\\w+)*", // Mint
			"(mageia|vectorlinux)[;\\s]", // Mageia/VectorLinux
			// Joli/Ubuntu/Debian/SUSE/Gentoo/Arch/Slackware
			// Fedora/Mandriva/CentOS/PCLinuxOS/RedHat/Zenwalk/Linpus
			"(joli|[kxln]?ubuntu|debian|[open]*suse|gentoo|(?=\\s)arch|slackware|fedora|mandriva|centos|pclinuxos|redhat|zenwalk|linpus)[\\/\\s-]?(?!chrom)([\\w\\.-]+)*",
			// Hurd/Linux
			"(hurd|linux)\\s?([\\w\\.]+)*", // Hurd/Linux
			"(gnu)\\s?([\\w\\.]+)*" // GNU
		],[.r(.name),.r(.version)]),
		Rule([
			"(cros)\\s[\\w]+\\s([\\w\\.]+\\w)", // Chromium OS
		],[.rf(.name,"chromium os"),.r(.version)]),
		Rule([
			"(sunos)\\s?([\\w\\.]+\\d)*", // Solaris
		],[.rf(.name,"solaris"),.r(.version)]),
		Rule([
			// BSD based
			"\\s([frentopc-]{0,4}bsd|dragonfly)\\s?([\\w\\.]+)*", // FreeBSD/NetBSD/OpenBSD/PC-BSD/DragonFly
		],[.r(.name),.r(.version)]),
		Rule([
			"(haiku)\\s(\\w+)", // Haiku
		],[.r(.name),.r(.version)]),
		Rule([
			"cfnetwork\\/.+darwin",
			"ip[honead]+(?:.*os\\s([\\w]+)\\slike\\smac|;\\sopera)", // iOS
		],[.rp(.version,"_", "."),.rf(.name,"ios")]),
		Rule([
			"(mac\\sos\\sx)\\s?([\\w\\s\\.]+\\w)*",
			"(macintosh|mac(?=_powerpc)\\s)" // Mac OS
		],[.rf(.name,"mac os"),.rp(.version,"_",".")]),
		Rule([
			// Other
			"((?:open)?solaris)[\\/\\s-]?([\\w\\.]+)*", // Solaris
			"(aix)\\s((\\d)(?=\\.|\\)|\\s)[\\w\\.]*)*", // AIX
			"(plan\\s9|minix|beos|os\\/2|amigaos|morphos|risc\\sos|openvms)", // Plan9/Minix/BeOS/OS2/AmigaOS/MorphOS/RISCOS/OpenVMS
			"(unix)\\s?([\\w\\.]+)*" // UNIX
		],[.r(.name),.r(.version)])
	]
	
}

// MARK: - Special Mapping Data

internal struct OldSafariMap: MappedKeys {
	public var map: [String:[String]] = [:]
	
	init() {
		self.map = [
			"1.0"   : ["/8"],
			"1.2"   : ["/1"],
			"1.3"   : ["/3"],
			"2.0"   : ["/412"],
			"2.0.2" : ["/416"],
			"2.0.3" : ["/417"],
			"2.0.4" : ["/419"],
			"?"     : ["/"]
		]
	}
}

internal struct AmazonDeviceMap: MappedKeys {
	public var map: [String:[String]] = [:]
	
	init() {
		self.map = [
			"Fire Phone" : ["SD", "KF"]
		]
	}
}

internal struct SprintVendorMap: MappedKeys {
	public var map: [String:[String]] = [:]
	
	init() {
		self.map = [
			"HTC" : ["APA"],
			"Sprint" : ["Sprint"]
		]
	}
}

internal struct SprintModelMap: MappedKeys {
	public var map: [String:[String]] = [:]
	
	init() {
		self.map = [
			"Evo Shift 4G" : ["7373KT"]
		]
	}
}

internal struct WindowsOSMap: MappedKeys {
	public var map: [String:[String]] = [:]
	
	init() {
		self.map = [
			"ME"        : ["4.90"],
			"NT 3.11"   : ["NT3.51"],
			"NT 4.0"    : ["NT4.0"],
			"2000"      : ["NT 5.0"],
			"XP"        : ["NT 5.1", "NT 5.2"],
			"Vista"     : ["NT 6.0"],
			"7"         : ["NT 6.1"],
			"8"         : ["NT 6.2"],
			"8.1"       : ["NT 6.3"],
			"10"        : ["NT 6.4", "NT 10.0"],
			"RT"        : ["ARM"]
		]
	}
}


// MARK: - String Regex Extension

public extension String {
	
	/// Return all matched groups extracted from self string using passed regexp
	///
	/// - Parameter regex: regular express used to filter
	/// - Returns: matching strings
	func matchingStrings(regex: NSRegularExpression) -> [String]? {
		let nsString = NSString(string: self)
		let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
		let matches = results.map { result in
			(0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
				? nsString.substring(with: result.range(at: $0))
				: ""
			}
		}
		// we are working only with the first matching group and inside with all sub strings (the first one is the group itself)
		guard let first_group = matches.first else { return nil }
		return first_group.count > 1 ? Array(first_group[1...]) : first_group
	}
	
	/// Replace string matching given regex with passed string
	///
	/// - Parameters:
	///   - pattern: regular expression
	///   - replaceWith: replacing value
	/// - Returns: new string; if error occurs the same input string is returned
	func replace(withRegex pattern: String, with replaceWith: String = "") -> String {
		do {
			let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
			let range = NSMakeRange(0, self.count)
			return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
		} catch {
			return self
		}
	}
}
