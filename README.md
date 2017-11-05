<p align="center" >
<img src="https://raw.githubusercontent.com/malcommac/UAParserSwift/master/logo.png" width=530px alt="UAParserSwift" title="UAParserSwift">
</p>

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CI Status](https://travis-ci.org/malcommac/UAParserSwift.svg)](https://travis-ci.org/malcommac/UAParserSwift) [![Version](https://img.shields.io/cocoapods/v/UAParserSwift.svg?style=flat)](http://cocoadocs.org/docsets/UAParserSwift) [![License](https://img.shields.io/cocoapods/l/UAParserSwift.svg?style=flat)](http://cocoadocs.org/docsets/UAParserSwift) [![Platform](https://img.shields.io/cocoapods/p/UAParserSwift.svg?style=flat)](http://cocoadocs.org/docsets/UAParserSwift)

<p align="center" >Identify browser, engine, OS, CPU and device/type model<br/>
Made with ♥ for Swift Server Side
<p/>
<p align="center" >★★ <b>Star our github repository to help us!</b> ★★</p>
<p align="center" >Created by <a href="http://www.danielemargutti.com">Daniele Margutti</a> (<a href="http://www.twitter.com/danielemargutti">@danielemargutti</a>)</p>

### What's UAParserSwift

UAParserSwift is a Swift-based library to parse User Agent string; it's a port of [ua-parser-js](https://github.com/faisalman/ua-parser-js) by Faisal Salman created to be mainly used in Swift Server Side applications ([Kitura](http://kitura.io), [Vapor](https://opencollective.com/vapor) etc.).
You can however use it on client side, all Apple's platforms are supported (iOS, macOS, tvOS and watchOS).

This library aims to identify detailed type of web browser, layout engine, operating system, cpu architecture, and device type/model, entirely from user-agent string with a relatively small footprint.

### Other Libraries you may like

I'm also working on several other projects you may like.
Take a look below:

<p align="center" >

| Library         | Description                                      |
|-----------------|--------------------------------------------------|
| [**SwiftDate**](https://github.com/malcommac/SwiftDate)       | The best way to manage date/timezones in Swift   |
| [**Hydra**](https://github.com/malcommac/Hydra)           | Write better async code: async/await & promises  |
| [**Flow**](https://github.com/malcommac/Flow) | A new declarative approach to table managment. Forget datasource & delegates. |
| [**SwiftRichString**](https://github.com/malcommac/SwiftRichString) | Elegant & Painless NSAttributedString in Swift   |
| [**SwiftLocation**](https://github.com/malcommac/SwiftLocation)   | Efficient location manager                       |
| [**SwiftMsgPack**](https://github.com/malcommac/SwiftMsgPack)    | Fast/efficient msgPack encoder/decoder           |
</p>


### Contents

* Documentation
* Supported Browsers
* Supported Devices
* Supported Engines
* Supported OSs
* Supported Architectures

* Unit Tests
* Installation
* License

### Documentation

Usage of UAParserSwift is pretty simple; just allocate an `UAParser` object along with the `User-Agent` string you want to parse.

```swift
let parser = UAParser(agent: "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7")
```

Now you can call one of these properties to get parsed data (all properties are lazy created in order to keep parser lightweight):

* `.browser`: return a `Browser` object with the browser's properties: `name`, `version`
* `.device`: return a `Device` object with device's informations: `vendor`,`type`,`model`
* `.engine`: return an `Engine` object with information about browser's engine: `name`,`version`
* `.os`: return an `OS` object with the information about host operation system: `name`,`version`
* `.cpu`: return a `CPU` object with the informations about host's device architecture: `identifier`


### Supported Browsers

**Name**:
```
Amaya, Android Browser, Arora, Avant, Baidu, Blazer, Bolt, Bowser, Camino, Chimera,
Chrome [WebView], Chromium, Comodo Dragon, Conkeror, Dillo, Dolphin, Doris, Edge,
Epiphany, Fennec, Firebird, Firefox, Flock, GoBrowser, iCab, ICE Browser, IceApe,
IceCat, IceDragon, Iceweasel, IE[Mobile], Iron, Jasmine, K-Meleon, Konqueror, Kindle,
Links, Lunascape, Lynx, Maemo, Maxthon, Midori, Minimo, MIUI Browser, [Mobile] Safari,
Mosaic, Mozilla, Netfront, Netscape, NetSurf, Nokia, OmniWeb, Opera [Mini/Mobi/Tablet],
PhantomJS, Phoenix, Polaris, QQBrowser, RockMelt, Silk, Skyfire, SeaMonkey, Sleipnir,
SlimBrowser, Swiftfox, Tizen, UCBrowser, Vivaldi, w3m, WeChat, Yandex
```

**Version**:
Determined dynamically

### Supported Devices

**Type**:

```
console, mobile, tablet, smarttv, wearable, embedded
```

**Vendor**:

```
Acer, Alcatel, Amazon, Apple, Archos, Asus, BenQ, BlackBerry, Dell, GeeksPhone,
Google, HP, HTC, Huawei, Jolla, Lenovo, LG, Meizu, Microsoft, Motorola, Nexian,
Nintendo, Nokia, Nvidia, OnePlus, Ouya, Palm, Panasonic, Pebble, Polytron, RIM,
Samsung, Sharp, Siemens, Sony[Ericsson], Sprint, Xbox, Xiaomi, ZTE
```

**Model**:
Determined dinamically

### Supported Engines

**Engine**:

```
Amaya, EdgeHTML, Gecko, iCab, KHTML, Links, Lynx, NetFront, NetSurf, Presto,
Tasman, Trident, w3m, WebKit
```

**Engine Version**:
Determined dinamically

### Supported OSs

**Name**:
```
AIX, Amiga OS, Android, Arch, Bada, BeOS, BlackBerry, CentOS, Chromium OS, Contiki,
Fedora, Firefox OS, FreeBSD, Debian, DragonFly, Gentoo, GNU, Haiku, Hurd, iOS,
Joli, Linpus, Linux, Mac OS, Mageia, Mandriva, MeeGo, Minix, Mint, Morph OS, NetBSD,
Nintendo, OpenBSD, OpenVMS, OS/2, Palm, PC-BSD, PCLinuxOS, Plan9, Playstation, QNX, RedHat,
RIM Tablet OS, RISC OS, Sailfish, Series40, Slackware, Solaris, SUSE, Symbian, Tizen,
Ubuntu, UNIX, VectorLinux, WebOS, Windows [Phone/Mobile], Zenwalk
```

**Version**:
Determined dinamically

### Supported Architectures

**Identifier**:
```
68k, amd64, arm[64], avr, ia[32/64], irix[64], mips[64], pa-risc, ppc, sparc[64]
```

### Unit Tests

Unit Tests are available under the [`Tests`](https://github.com/malcommac/UAParserSwift/tree/master/Tests) directory; actually they are the same tests available for ua-parser-js and all are passed successfully.

### Installation



### License

Dual licensed under GPLv2 & MIT

Copyright © 2017 Daniele Margutti <hello@danielemargutti.com>
Original [ua-parser-js](http://faisalman.github.io/ua-parser-js) Copyright: Copyright © 2012-2016 Faisal Salman <fyzlman@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
