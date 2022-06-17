//
//  LocalizationTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest

class LocalizationTests: XCTestCase {
  
    func test_allLocalization() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let localizationBundles = allLocalizationBundles(bundle: bundle)
        let localizationKeys = allLocalizationKeys(in: localizationBundles, table: table)
        
        localizationKeys.forEach { key in
            localizationBundles.forEach { current in
                let localized = NSLocalizedString(key, tableName: table, bundle: current.bundle, value: "", comment: "")
                
                if key == localized {
                    let language = Locale.current.localizedString(forLanguageCode: current.localization) ?? ""
                    
                    XCTFail("Missing \(language) (\(current.localization)) translation for \(key) in \(table).strings file")
                }
            }
        }
    }
    typealias LocalizationBundle = (bundle: Bundle, localization: String)
    
    private func allLocalizationBundles(bundle: Bundle) -> [LocalizationBundle] {
        return bundle.localizations.compactMap { localization in
            guard
                let path = bundle.path(forResource: localization, ofType:"lproj"),
                let localizationBundle = Bundle(path: path) else {
                XCTFail("Unable to find path for \(localization) bundle")
                return nil
            }
            
            return (localizationBundle, localization)
        }
    }
    
    private func allLocalizationKeys(in bundles: [LocalizationBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
        
        return bundles.reduce([]) { acc, localBundle in
            guard
                let stringsFilePath = localBundle.bundle.path(forResource: table, ofType: "strings"),
                let dict = NSDictionary(contentsOfFile: stringsFilePath),
                let allKeys =  dict.allKeys as? [String] else {
                XCTFail("Unable to find \(table).strings for \(localBundle.localization) bundle")
                return acc
            }
            
            return acc.union(Set(allKeys))
        }
    }
    

}
