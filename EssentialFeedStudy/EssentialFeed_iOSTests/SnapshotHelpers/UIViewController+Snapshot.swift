//
//  UIViewController+Snapshot.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/27/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}
