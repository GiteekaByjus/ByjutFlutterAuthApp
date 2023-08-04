//
//  TLUserDefaults.swift
//  ThinkandLearn
//
//  Created by Sreeram R on 03/03/16.
//  Copyright © 2016 Think & Learn Pvt Ltd. All rights reserved.
//

//Adding this comment to check if version is > 0.9.4
import UIKit

@objc public class TLUserDefaults: NSObject {
    @objc public static let sharedManager = TLUserDefaults()

    public let userDefaults = UserDefaults.standard
    
}
