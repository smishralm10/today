//
//  HomeViewController+Actions.swift
//  Today
//
//  Created by Shreyansh Mishra on 19/12/22.
//

import Foundation

extension HomeViewController {
    @objc func eventStoreChanged(_ notification: NSNotification) {
        reminderStoreChanged()
    }
}
