//
//  HTTPURLResponse+isOK.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    var isOK: Bool { statusCode == 200 }
}
