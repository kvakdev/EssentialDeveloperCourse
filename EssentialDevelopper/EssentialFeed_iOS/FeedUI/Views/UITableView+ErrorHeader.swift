//
//  UITableView+ErrorHeader.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit


extension UITableView {
    func handleFeedLoadingError(_ message: String?) {
        if let error = message {
            let headerView = FeedErrorHeaderView(errorMessage: error)
            tableHeaderView = headerView
        } else {
            tableHeaderView = nil
        }
    }
}
