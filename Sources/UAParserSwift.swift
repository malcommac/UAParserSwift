//
//  UAParserSwift.swift
//  UAParserSwift
//
//  Created by Daniele Margutti on 01/11/2017.
//  Copyright © 2017 UAParserSwift. All rights reserved.
//

import Foundation

public enum Key {
	case model
	case name
	case vendor
	case type
	case version
	case arch
}


// se un eele
public struct Rule {
	public private(set) var regexp: [String]
	public private(set) var funcs: [Funcs]

	public init(_ regexp: [String], _ funcs: [Funcs]) {
		self.regexp = regexp
		self.funcs = funcs
	}
}

public protocol MappedKeys {
	var map: [String:[String]] { get }
}

public struct OldSafariMap: MappedKeys {
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

public struct AmazonDeviceMap: MappedKeys {
	public var map: [String:[String]] = [:]
	
	init() {
		self.map = [
			"Fire Phone" : ["SD", "KF"]
		]
	}
}

public struct SprintVendorMap: MappedKeys {
	public var map: [String:[String]] = [:]
	
	init() {
		self.map = [
			"HTC" : ["APA"],
			"Sprint" : ["Sprint"]
		]
	}
}

public struct SprintModelMap: MappedKeys {
	public var map: [String:[String]] = [:]
	
	init() {
		self.map = [
			"Evo Shift 4G" : ["7373KT"]
		]
	}
}

public struct WindowsOSMap: MappedKeys {
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


public enum Funcs {
	case r(_: Key)
	case rf(_: Key, _: String)
	case rp(_: Key, _: String, _: String)
	case mp(_: Key, _: MappedKeys)
	
	func exec(in: Result) {
		
	}
}

public class Result {
	
}

public struct Regexes {
	
	public static let browsers: [Rule] = [
		Rule([
			"/(opera\\smini)\\/([\\w\\.-]+)/i", // Opera Mini
			"/(opera\\s[mobiletab]+).+version\\/([\\w\\.-]+)/i", // Opera Mobi/Tablet
			"/(opera).+version\\/([\\w\\.]+)/i", // Opera > 9.80
			"/(opera)[\\/\\s]+([\\w\\.]+)/i" // Opera < 9.80
		],[.r(.name),.r(.version)]),
		Rule([
			"/(opios)[\\/\\s]+([\\w\\.]+)/i", // Opera mini on iphone >= 8.0
		], [.rf(.name,"Opera Mini"), .r(.version)]),
		Rule([
			"/\\s(opr)\\/([\\w\\.]+)/i", // Opera Webkit
		], [.rf(.name,"Opera"),.r(.version)]),
		Rule([
			// Mixed
			"/(kindle)\\/([\\w\\.]+)/i", // Kindle
			"/(lunascape|maxthon|netfront|jasmine|blazer)[\\/\\s]?([\\w\\.]+)*/i", // Lunascape/Maxthon/Netfront/Jasmine/Blazer
			// Trident based
			"/(avant\\s|iemobile|slim|baidu)(?:browser)?[\\/\\s]?([\\w\\.]*)/i", // Avant/IEMobile/SlimBrowser/Baidu
			"/(?:ms|\\()(ie)\\s([\\w\\.]+)/i", // Internet Explorer
			// Webkit/KHTML based
			"/(rekonq)\\/([\\w\\.]+)*/i", // Rekonq
			"/(chromium|flock|rockmelt|midori|epiphany|silk|skyfire|ovibrowser|bolt|iron|vivaldi|iridium|phantomjs|bowser)\\/([\\w\\.-]+)/i" // Chromium/Flock/RockMelt/Midori/Epiphany/Silk/Skyfire/Bolt/Iron/Iridium/PhantomJS/Bowser
		], [.r(.name),.r(.version)]),
		Rule([
			"/(trident).+rv[:\\s]([\\w\\.]+).+like\\sgecko/i", // IE11
		], [.rf(.name,"IE"),.r(.version)]),
		Rule([
			"/(edge)\\/((\\d+)?[\\w\\.]+)/i", // Microsoft Edge
		], [.r(.name),.r(.version)]),
		Rule([
			"/(yabrowser)\\/([\\w\\.]+)/i", // Yandex
		], [.rf(.name,"Yandex"),.r(.version)]),
		Rule([
			"/(puffin)\\/([\\w\\.]+)/i", // Puffin
		], [.rf(.name,"Puffin"),.r(.version)]),
		Rule([
			"/((?:[\\s\\/])uc?\\s?browser|(?:juc.+)ucweb)[\\/\\s]?([\\w\\.]+)/i"  // UCBrowser
		], [.rf(.name,"UCBrowser"),.r(.version)]),
		Rule([
			"/(comodo_dragon)\\/([\\w\\.]+)/i", // Comodo Dragon
		], [.rp(.name,"/_/g", " "), .r(.version)]),
		Rule([
			"/(micromessenger)\\/([\\w\\.]+)/i", // WeChat
		], [.rf(.name,"WeChat"),.r(.version)]),
		Rule([
			"/(QQ)\\/([\\d\\.]+)/i", // QQ, aka ShouQ
		], [.r(.name),.r(.version)]),
		Rule([
			"/m?(qqbrowser)[\\/\\s]?([\\w\\.]+)/i", // QQBrowser
		], [.r(.name),.r(.version)]),
		Rule([
			"/xiaomi\\/miuibrowser\\/([\\w\\.]+)/i", // MIUI Browser
		], [.r(.version), .rf(.name,"MIU Browser")]),
		Rule([
			"/;fbav\\/([\\w\\.]+);/i", // Facebook App for iOS & Android
		], [.r(.version), .rf(.name,"Facebook")]),
		Rule([
			"/headlesschrome(?:\\/([\\w\\.]+)|\\s)/i", // Chrome Headless
		], [.r(.version),.rf(.name,"Chrome Headless")]),
		Rule([
			"/\\swv\\).+(chrome)\\/([\\w\\.]+)/i", // Chrome WebView
		], [.rp(.name,"/(.+)/","$1 WebView"),.r(.version)]),
		Rule([
			"/((?:oculus|samsung)browser)\\/([\\w\\.]+)/i" // Oculus / Samsung Browser
		], [.rp(.name,"/(.+(?:g|us))(.+)/","$1 $2"),.r(.version)]),
		Rule([
			"/android.+version\\/([\\w\\.]+)\\s+(?:mobile\\s?safari|safari)*/i", // Android Browser
		],[.r(.version),.rf(.name,"Android Browser")]),
		Rule([
			"/(chrome|omniweb|arora|[tizenoka]{5}\\s?browser)\\/v?([\\w\\.]+)/i", // Chrome/OmniWeb/Arora/Tizen/Nokia
		],[.r(.name),.r(.version)]),
		Rule([
			"/(dolfin)\\/([\\w\\.]+)/i", // Dolphin
		], [.rf(.name,"Dolphin"),.r(.version)]),
		Rule([
			"/((?:android.+)crmo|crios)\\/([\\w\\.]+)/i", // Chrome for Android/iOS
		],[.rf(.name,"Chrome"),.r(.version)]),
		Rule([
			"/(coast)\\/([\\w\\.]+)/i", // Opera Coast
		],[.rf(.name,"Opera Coast"),.r(.version)]),
		Rule([
			"/fxios\\/([\\w\\.-]+)/i", // Firefox for iOS
		], [.r(.version),.rf(.name,"Firefox")]),
		Rule([
			"/version\\/([\\w\\.]+).+?mobile\\/\\w+\\s(safari)/i", // Mobile Safari
		], [.r(.version),.rf(.name,"Mobile Safari")]),
		Rule([
			"/version\\/([\\w\\.]+).+?(mobile\\s?safari|safari)/i", // Safari & Safari Mobile
		], [.r(.version),.r(.name)]),
		Rule([
			"/webkit.+?(gsa)\\/([\\w\\.]+).+?(mobile\\s?safari|safari)(\\/[\\w\\.]+)/i", // Google Search Appliance on iOS
		], [.rf(.name,"GSA"),.r(.version)]),
		Rule([
			"/webkit.+?(mobile\\s?safari|safari)(\\/[\\w\\.]+)/i", // Safari < 3.0
		], [.r(.name),.mp(.version, OldSafariMap())]),
		Rule([
			"/(konqueror)\\/([\\w\\.]+)/i,", // Konqueror
			"/(webkit|khtml)\\/([\\w\\.]+)/i",
		],[.r(.name),.r(.version)]),
		Rule([
			// Gecko based
			"/(navigator|netscape)\\/([\\w\\.-]+)/i", // Netscape
		],[.rf(.name,"Netscape"),.r(.version)]),
		Rule([
			"/(swiftfox)/i", // Swiftfox
			"/(icedragon|iceweasel|camino|chimera|fennec|maemo\\sbrowser|minimo|conkeror)[\\/\\s]?([\\w\\.\\+]+)/i", // IceDragon/Iceweasel/Camino/Chimera/Fennec/Maemo/Minimo/Conkeror
			"/(firefox|seamonkey|k-meleon|icecat|iceape|firebird|phoenix)\\/([\\w\\.-]+)/i", // Firefox/SeaMonkey/K-Meleon/IceCat/IceApe/Firebird/Phoenix
			"/(mozilla)\\/([\\w\\.]+).+rv\\:.+gecko\\/\\d+/i", // Mozilla
			// Other
			"/(polaris|lynx|dillo|icab|doris|amaya|w3m|netsurf|sleipnir)[\\/\\s]?([\\w\\.]+)/i", // Polaris/Lynx/Dillo/iCab/Doris/Amaya/w3m/NetSurf/Sleipnir
			"/(links)\\s\\(([\\w\\.]+)/i", // Links,
			"/(gobrowser)\\/?([\\w\\.]+)*/i", // GoBrowser
			"/(ice\\s?browser)\\/v?([\\w\\._]+)/i", // ICE Browser
			"/(mosaic)[\\/\\s]([\\w\\.]+)/i", // Mosaic
		], [.r(.name),.r(.version)])
	]
	
	public static let cpu: [Rule] = [
		Rule([
			"/(?:(amd|x(?:(?:86|64)[_-])?|wow|win)64)[;\\)]/i", // AMD64
			], [.rf(.arch,"amd64")]),
		Rule([
			"/(ia32(?=;))/i" // IA32 (quicktime)
		], [.r(.arch)]),
		Rule([
			"/((?:i[346]|x)86)[;\\)]/i" // // IA32
		],[.rf(.arch,"ia32")]),
		Rule([
			"/windows\\s(ce|mobile);\\sppc;/i", // PocketPC mistakenly identified as PowerPC
		],[.rf(.arch,"arm")]),
		Rule([
			"/((?:ppc|powerpc)(?:64)?)(?:\\smac|;|\\))/i", // PowerPC
		],[.rp(.arch,"/ower/","")]),
		Rule([
			"/(sun4\\w)[;\\)]/i", // SPARC
		],[.rf(.arch,"sparc")]),
		Rule([
			"/((?:avr32|ia64(?=;))|68k(?=\\))|arm(?:64|(?=v\\d+;))|(?=atmel\\s)avr|(?:irix|mips|sparc)(?:64)?(?=;)|pa-risc)/i", // IA64, 68K, ARM/64, AVR/32, IRIX/64, MIPS/64, SPARC/64, PA-RISC
		],[.r(.arch)])
	]
	
	public static let device: [Rule] = [
		Rule([
			"/\\((ipad|playbook);[\\w\\s\\);-]+(rim|apple)/i", // iPad/PlayBook
		],[.r(.model),.r(.vendor),.rf(.type,"tablet")]),
		Rule([
			"/applecoremedia\\/[\\w\\.]+ \\((ipad)/", // iPad
		],[.r(.model),.rf(.vendor,"apple"),.rf(.type,"tablet")]),
		Rule([
			"/(apple\\s{0,1}tv)/i", // Apple TV
		],[.rf(.model,"apple tv"),.rf(.vendor,"apple")]),
		Rule([
			"/(archos)\\s(gamepad2?)/i", // Archos
			"/(hp).+(touchpad)/i", // HP TouchPad
			"/(hp).+(tablet)/i", // HP Tablet
			"/(kindle)\\/([\\w\\.]+)/i", // Kindle
			"/\\s(nook)[\\w\\s]+build\\/(\\w+)/i", // Nook
			"/(dell)\\s(strea[kpr\\s\\d]*[\\dko])/i", // Dell Streak
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/(kf[A-z]+)\\sbuild\\/[\\w\\.]+.*silk\\//i", // Kindle Fire HD
		],[.r(.model),.rf(.vendor,"amazon"),.rf(.type,"tablet")]),
		Rule([
			"/(sd|kf)[0349hijorstuw]+\\sbuild\\/[\\w\\.]+.*silk\\//i", // Fire Phone
		],[.mp(.model,AmazonDeviceMap()),.rf(.vendor,"amazon"),.rf(.type,"mobile")]),
		Rule([
			"/\\((ip[honed|\\s\\w*]+);.+(apple)/i", // iPod/iPhone
		],[.r(.model),.r(.vendor),.rf(.type,"mobile")]),
		Rule([
			"/\\((ip[honed|\\s\\w*]+);/i", // iPod/iPhone
		],[.r(.model),.rf(.vendor,"apple"),.rf(.type,"mobile")]),
		Rule([
			"/(blackberry)[\\s-]?(\\w+)/i", // BlackBerry
			"/(blackberry|benq|palm(?=\\-)|sonyericsson|acer|asus|dell|meizu|motorola|polytron)[\\s_-]?([\\w-]+)*/i", // BenQ/Palm/Sony-Ericsson/Acer/Asus/Dell/Meizu/Motorola/Polytron
			"/(hp)\\s([\\w\\s]+\\w)/i", // HP iPAQ
			"/(asus)-?(\\w+)/i", // Asus
		],[.r(.vendor),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"/\\(bb10;\\s(\\w+)/i", // BlackBerry 10
		],[.r(.model),.rf(.vendor,"BlackBerry"),.rf(.type,"mobile")]),
		Rule([
			"/android.+(transfo[prime\\s]{4,10}\\s\\w+|eeepc|slider\\s\\w+|nexus 7|padfone)/i", // Asus Tablets
		],[.r(.model),.rf(.vendor,"asus"),.rf(.type,"tablet")]),
		Rule([
			"/(sony)\\s(tablet\\s[ps])\\sbuild\\//i", // Sony Xperia
			"/(sony)?(?:sgp.+)\\sbuild\\//i"
		], [.rf(.vendor,"sony"),.rf(.model,"xperia tablet"),.rf(.type,"tablet")]),
		Rule([
			"/android.+\\s([c-g]\\d{4}|so[-l]\\w+)\\sbuild\\//i" // Sony
		],[.r(.model),.rf(.vendor,"sony"),.rf(.type,"mobile")]),
		Rule([
			"/\\s(ouya)\\s/i", // Ouya
			"/(nintendo)\\s([wids3u]+)/i", // Nintendo
		],[.r(.vendor),.r(.model),.rf(.type,"console")]),
		Rule([
			"/android.+;\\s(shield)\\sbuild/i", // Nvidia
		], [.r(.model),.rf(.vendor,"sony"),.rf(.type,"console")]),
		Rule([
			"/(playstation\\s[34portablevi]+)/i", // Playstation
		],[.r(.model),.rf(.vendor,"sony"),.rf(.type,"console")]),
		Rule([
			"/(sprint\\s(\\w+))/i", // Sprint Phones
		],[.mp(.vendor,SprintVendorMap()), .mp(.model, SprintModelMap()), .rf(.type,"mobile")]),
		Rule([
			"/(lenovo)\\s?(S(?:5000|6000)+(?:[-][\\w+]))/i", // Lenovo tablets
		], [.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/(htc)[;_\\s-]+([\\w\\s]+(?=\\))|\\w+)*/i", // HTC
			"/(zte)-(\\w+)*/i", // ZTE,
			"/(alcatel|geeksphone|lenovo|nexian|panasonic|(?=;\\s)sony)[_\\s-]?([\\w-]+)*/i", // Alcatel/GeeksPhone/Lenovo/Nexian/Panasonic/Sony
		], [.r(.vendor),.rp(.model,"/_/g"," "),.rf(.type,"mobile")]),
		Rule([
			"/(nexus\\s9)/i", // HTC Nexus 9
		], [.r(.model),.rf(.vendor,"htc"),.rf(.type,"tablet")]),
		Rule([
			"/d\\/huawei([\\w\\s-]+)[;\\)]/i", // Huawei
			"/(nexus\\s6p)/i"
		],[.r(.model),.rf(.vendor,"huawei"),.rf(.type,"mobile")]),
		Rule([
			"/(microsoft);\\s(lumia[\\s\\w]+)/i", // Microsoft Lumia
		],[.r(.vendor),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"/[\\s\\(;](xbox(?:\\sone)?)[\\s\\);]/i", // Microsoft Xbox
		],[.r(.model),.rf(.vendor,"microsoft"),.rf(.type,"console")]),
		Rule([
			"/(kin\\.[onetw]{3})/i", // Microsoft Kin
		],[.rp(.model,"/\\./g"," "),.rf(.vendor,"microsoft"),.rf(.type,"mobile")]),
		Rule([
			"/\\s(milestone|droid(?:[2-4x]|\\s(?:bionic|x2|pro|razr))?(:?\\s4g)?)[\\w\\s]+build\\//i", // Motorola
			"/mot[\\s-]?(\\w+)*/i",
			"/(XT\\d{3,4}) build\\//i",
			"/(nexus\\s6)/i"
		],[.r(.model),.rf(.vendor,"motorola"),.rf(.type,"mobile")]),
		Rule([
			"/android.+\\s(mz60\\d|xoom[\\s2]{0,2})\\sbuild\\//i", // Motorola
		],[.r(.model),.rf(.vendor,"motorola"),.rf(.type,"tablet")]),
		Rule([
			"/hbbtv\\/\\d+\\.\\d+\\.\\d+\\s+\\([\\w\\s]*;\\s*(\\w[^;]*);([^;]*)/i", // HbbTV devices
		],[.r(.vendor),.r(.model),.rf(.type,"smarttv")]),
		Rule([
			"/hbbtv.+maple;(\\d+)/i",
		],[.rp(.model,"/^/","SmartTV"),.rf(.vendor,"samsung"),.rf(.type,"smarttv")]),
		Rule([
			"/\\(dtv[\\);].+(aquos)/i", // Sharp
		],[.r(.model),.rf(.vendor,"sharp"),.rf(.type,"smarttv")]),
		Rule([
			"/android.+((sch-i[89]0\\d|shw-m380s|gt-p\\d{4}|gt-n\\d+|sgh-t8[56]9|nexus 10))/i", // Samsung
			"/((SM-T\\w+))/i"
		],[.rf(.vendor,"samsung"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/smart-tv.+(samsung)/i",
		],[.r(.vendor),.rf(.type,"smarttv"),.r(.model)]),
		Rule([
			"/((s[cgp]h-\\w+|gt-\\w+|galaxy\\snexus|sm-\\w[\\w\\d]+))/i",
			"/(sam[sung]*)[\\s-]*(\\w+-?[\\w-]*)*/i",
			"/sec-((sgh\\w+))/i"
		],[.rf(.vendor,"samsung"),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"/sie-(\\w+)*/i", // Siemens
		],[.r(.model),.rf(.vendor,"siemes"),.rf(.type,"mobile")]),
		Rule([
			"/(maemo|nokia).*(n900|lumia\\s\\d+)/i", // Nokia
			"/(nokia)[\\s_-]?([\\w-]+)*/i",
		],[.rf(.vendor,"nokia"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/android\\s3\\.[\\s\\w;-]{10}(a\\d{3})/i", // Acer
		],[.r(.model),.rf(.vendor,"acer"),.rf(.type,"tablet")]),
		Rule([
			"/android.+([vl]k\\-?\\d{3})\\s+build/i", // LG Tablet
		],[.r(.model),.rf(.vendor,"lg"),.rf(.type,"tablet")]),
		Rule([
			"/android\\s3\\.[\\s\\w;-]{10}(lg?)-([06cv9]{3,4})/i", // LG Tablet
		],[.rf(.vendor,"lg"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/(lg) netcast\\.tv/i", // LG SmartTV
		],[.r(.vendor),.r(.model),.rf(.type,"smarttv")]),
		Rule([
			"/(nexus\\s[45])/i", // LG
			"/lg[e;\\s\\/-]+(\\w+)*/i",
			"/android.+lg(\\-?[\\d\\w]+)\\s+build/i",
		],[.r(.model),.rf(.vendor,"lg"),.rf(.type,"mobile")]),
		Rule([
			"/android.+(ideatab[a-z0-9\\-\\s]+)/i", // Lenovo
		],[.r(.model),.rf(.vendor,"lenovo"),.rf(.type,"tablet")]),
		Rule([
			"/linux;.+((jolla));/i", // Jolla
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/((pebble))app\\/[\\d\\.]+\\s/i", // Pebble
		],[.r(.vendor),.r(.model),.rf(.type,"wearable")]),
		Rule([
			"/android.+;\\s(oppo)\\s?([\\w\\s]+)\\sbuild/i", // OPPO
		],[.r(.vendor),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"/crkey/i", // Google Chromecast
		],[.rf(.model,"chromecast"),.rf(.vendor,"google")]),
		Rule([
			"/android.+;\\s(glass)\\s\\d/i", // Google Glass
		],[.r(.model),.rf(.vendor,"google"),.rf(.type,"wearable")]),
		Rule([
			"/android.+;\\s(pixel c)\\s/i", // Google Pixel C
		],[.r(.model),.rf(.vendor,"google"),.rf(.type,"tablet")]),
		Rule([
			"/android.+;\\s(pixel xl|pixel)\\s/i", // Google Pixel
		],[.r(.model),.rf(.vendor,"google"),.rf(.type,"mobile")]),
		Rule([
			"/android.+(\\w+)\\s+build\\/hm\\1/i", // Xiaomi Hongmi 'numeric' models
			"/android.+(hm[\\s\\-_]*note?[\\s_]*(?:\\d\\w)?)\\s+build/i", // Xiaomi Hongmi
			"/android.+(mi[\\s\\-_]*(?:one|one[\\s_]plus|note lte)?[\\s_]*(?:\\d\\w)?)\\s+build/i", // Xiaomi Mi
			"/android.+(redmi[\\s\\-_]*(?:note)?(?:[\\s_]*[\\w\\s]+)?)\\s+build/i", // Redmi Phones
		],[.rp(.model,"/_/g"," "), .rf(.vendor,"xiaomi"),.rf(.type,"mobile")]),
		Rule([
			"/android.+(mi[\\s\\-_]*(?:pad)?(?:[\\s_]*[\\w\\s]+)?)\\s+build/i" // Mi Pad tablets
		],[.rp(.model,"/_/g"," "), .rf(.vendor,"xiaomi"),.rf(.type,"tablet")]),
		Rule([
			"/android.+;\\s(m[1-5]\\snote)\\sbuild/i", // Meizu Tablet
		],[.r(.model),.rf(.vendor,"meizu"),.rf(.type,"tablet")]),
		Rule([
			"/android.+a000(1)\\s+build/i", // OnePlus
		],[.r(.model),.rf(.vendor,"oneplus"),.rf(.type,"mobile")]),
		Rule([
			"/android.+[;\\/]\\s*(RCT[\\d\\w]+)\\s+build/i", // RCA Tablets
		],[.r(.model),.rf(.vendor,"rca"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(Venue[\\d\\s]*)\\s+build/i" // // Dell Venue Tablets
		],[.r(.model),.rf(.vendor,"dell"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(Q[T|M][\\d\\w]+)\\s+build/i", // Verizon Tablet
		],[.r(.model),.rf(.vendor,"verizon"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s+(Barnes[&\\s]+Noble\\s+|BN[RT])(V?.*)\\s+build/i", // Barnes & Noble Tablet
		],[.rf(.vendor,"barnes & noble"), .r(.model),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s+(TM\\d{3}.*\\b)\\s+build/i", // Barnes & Noble Tablet
		],[.r(.model),.rf(.vendor,"nuvision"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(zte)?.+(k\\d{2})\\s+build/i", // ZTE K Series Tablet
		],[.rf(.vendor,"zte"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(gen\\d{3})\\s+build.*49h/i", // Swiss GEN Mobile
		],[.r(.model),.rf(.vendor,"swiss"),.rf(.type,"mobile")]),
		Rule([
			"/android.+[;\\/]\\s*(zur\\d{3})\\s+build/i", // Swiss ZUR Tablet
		],[.r(.model),.rf(.vendor,"swiss"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*((Zeki)?TB.*\\b)\\s+build/i", // Zeki Tablets
		],[.r(.model),.rf(.vendor,"zeki"),.rf(.type,"tablet")]),
		Rule([
			"/(android).+[;\\/]\\s+([YR]\\d{2}x?.*)\\s+build/i", // Dragon Touch Tablet
			"/android.+[;\\/]\\s+(Dragon[\\-\\s]+Touch\\s+|DT)(.+)\\s+build/i",
		],[.rf(.vendor,"dragon touch"),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(NS-?.+)\\s+build/i", // Insignia Tablets
		],[.r(.model),.rf(.vendor,"insigna"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*((NX|Next)-?.+)\\s+build/i", // NextBook Tablets
		],[.r(.model),.rf(.vendor,"nextbook"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(Xtreme\\_?)?(V(1[045]|2[015]|30|40|60|7[05]|90))\\s+build/i", // Voice Xtreme Phones
		],[.rf(.vendor,"lvtel"),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"/android.+[;\\/]\\s*(LVTEL\\-?)?(V1[12])\\s+build/i", // LvTel Phones
		],[.rf(.vendor,"lvtel"),.r(.model),.rf(.type,"mobile")]),
		Rule([
			"/android.+[;\\/]\\s*(V(100MD|700NA|7011|917G).*\\b)\\s+build/i" // Envizen Tablets
		],[.r(.model),.rf(.vendor,"envizen"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(Le[\\s\\-]+Pan)[\\s\\-]+(.*\\b)\\s+build/i", // Le Pan Tablets
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(Trio[\\s\\-]*.*)\\s+build/i", // MachSpeed Tablets
		],[.r(.model),.rf(.vendor,"machspeed"),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*(Trinity)[\\-\\s]*(T\\d{3})\\s+build/i", // Trinity Tablets
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/android.+[;\\/]\\s*TU_(1491)\\s+build/i", // Rotor Tablets
		],[.r(.model),.rf(.vendor,"rotor"),.rf(.type,"tablet")]),
		Rule([
			"/android.+(KS(.+))\\s+build/i", // Amazon Kindle Tablets
		],[.r(.model),.rf(.vendor,"amazon"),.rf(.type,"tablet")]),
		Rule([
			"/android.+(Gigaset)[\\s\\-]+(Q.+)\\s+build/i]", // Gigaset Tablets
		],[.r(.vendor),.r(.model),.rf(.type,"tablet")]),
		Rule([
			"/\\s(tablet|tab)[;\\/]/i", // Unidentifiable Tablet
			"/\\s(mobile)(?:[;\\/]|\\ssafari)/i", // Unidentifiable Mobile
		],[.r(.type),.r(.vendor),.r(.model)]),
		Rule([
			"/(android.+)[;\\/].+build/i", // Generic Android Device
		],[.r(.model),.rf(.vendor,"generic")])
	]
	
	public static let engine: [Rule] = [
		Rule([
			"/windows.+\\sedge\\/([\\w\\.]+)/i", // EdgeHTML
		],[.r(.version),.rf(.name,"EdgeHTML")]),
		Rule([
			"/(presto)\\/([\\w\\.]+)/i", // Presto
			"/(webkit|trident|netfront|netsurf|amaya|lynx|w3m)\\/([\\w\\.]+)/i", // WebKit/Trident/NetFront/NetSurf/Amaya/Lynx/w3m
			"/(khtml|tasman|links)[\\/\\s]\\(?([\\w\\.]+)/i", // KHTML/Tasman/Links
			"/(icab)[\\/\\s]([23]\\.[\\d\\.]+)/i" // iCab
		],[.r(.name),.r(.version)])
	]
	
	public static let os: [Rule] = [
		Rule([
			// Windows based
			"/microsoft\\s(windows)\\s(vista|xp)/i", // Windows (iTunes)
		],[.r(.name),.r(.version)]),
		Rule([
			"/(windows)\\snt\\s6\\.2;\\s(arm)/i", // Windows RT
			"/(windows\\sphone(?:\\sos)*)[\\s\\/]?([\\d\\.\\s]+\\w)*/i", // Windows Phone
			"/(windows\\smobile|windows)[\\s\\/]?([ntce\\d\\.\\s]+\\w)/i"
		],[.r(.name),.mp(.version,WindowsOSMap())]),
		Rule([
			// Mobile/Embedded OS
			"/\\((bb)(10);/i" // BlackBerry 10
		],[.rf(.name,"blackberry"),.r(.version)]),
		Rule([
			"/(blackberry)\\w*\\/?([\\w\\.]+)*/i",  // Blackberry
			"/(tizen)[\\/\\s]([\\w\\.]+)/i", // Tizen
			"/(android|webos|palm\\sos|qnx|bada|rim\\stablet\\sos|meego|contiki)[\\/\\s-]?([\\w\\.]+)*/i", // Android/WebOS/Palm/QNX/Bada/RIM/MeeGo/Contiki
			"/linux;.+(sailfish);/i" // Sailfish OS
		],[.r(.name),.r(.version)]),
		Rule([
			"/(symbian\\s?os|symbos|s60(?=;))[\\/\\s-]?([\\w\\.]+)*/i", // Symbian
		],[.rf(.name,"symbian"),.r(.version)]),
		Rule([
			"/\\((series40);/i", // Series 40
		],[.r(.name)]),
		Rule([
			"/mozilla.+\\(mobile;.+gecko.+firefox/i", // Firefox OS
		],[.rf(.name,"firefox os"),.r(.version)]),
		Rule([
			// Console
			"/(nintendo|playstation)\\s([wids34portablevu]+)/i", // Nintendo/Playstation
			// GNU/Linux based
			"/(mint)[\\/\\s\\(]?(\\w+)*/i", // Mint
			"/(mageia|vectorlinux)[;\\s]/i", // Mageia/VectorLinux
			// Joli/Ubuntu/Debian/SUSE/Gentoo/Arch/Slackware
			// Fedora/Mandriva/CentOS/PCLinuxOS/RedHat/Zenwalk/Linpus
			"/(joli|[kxln]?ubuntu|debian|[open]*suse|gentoo|(?=\\s)arch|slackware|fedora|mandriva|centos|pclinuxos|redhat|zenwalk|linpus)[\\/\\s-]?(?!chrom)([\\w\\.-]+)*/i",
			// Hurd/Linux
			"/(hurd|linux)\\s?([\\w\\.]+)*/i", // Hurd/Linux
			"/(gnu)\\s?([\\w\\.]+)*/i" // GNU
		],[.r(.name),.r(.version)]),
		Rule([
			"/(cros)\\s[\\w]+\\s([\\w\\.]+\\w)/i", // Chromium OS
		],[.rf(.name,"chromium os"),.r(.version)]),
		Rule([
			"/(sunos)\\s?([\\w\\.]+\\d)*/i", // Solaris
		],[.rf(.name,"solaris"),.r(.version)]),
		Rule([
			// BSD based
			"/\\s([frentopc-]{0,4}bsd|dragonfly)\\s?([\\w\\.]+)*/i", // FreeBSD/NetBSD/OpenBSD/PC-BSD/DragonFly
		],[.r(.name),.r(.version)]),
		Rule([
			"/(haiku)\\s(\\w+)/i", // Haiku
		],[.r(.name),.r(.version)]),
		Rule([
			"/cfnetwork\\/.+darwin/i",
			"/ip[honead]+(?:.*os\\s([\\w]+)\\slike\\smac|;\\sopera)/i", // iOS
		],[.rp(.version,"/_/g", "."),.rf(.name,"ios")]),
		Rule([
			"/(mac\\sos\\sx)\\s?([\\w\\s\\.]+\\w)*/i",
			"/(macintosh|mac(?=_powerpc)\\s)/i" // Mac OS
		],[.rf(.name,"mac os"),.rp(.version,"/_/g",".")]),
		Rule([
			// Other
			"/((?:open)?solaris)[\\/\\s-]?([\\w\\.]+)*/i", // Solaris
			"/(aix)\\s((\\d)(?=\\.|\\)|\\s)[\\w\\.]*)*/i", // AIX
			"/(plan\\s9|minix|beos|os\\/2|amigaos|morphos|risc\\sos|openvms)/i", // Plan9/Minix/BeOS/OS2/AmigaOS/MorphOS/RISCOS/OpenVMS
			"/(unix)\\s?([\\w\\.]+)*/i" // UNIX
		],[.r(.name),.r(.version)])
	]
	
}
