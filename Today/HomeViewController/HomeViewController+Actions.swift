//
//  HomeViewController+Actions.swift
//  Today
//
//  Created by Shreyansh Mishra on 19/12/22.
//

import Foundation
import UIKit

extension HomeViewController {
    @objc func eventStoreChanged(_ notification: NSNotification) {
        reminderStoreChanged()
    }
    
    @objc func didPressCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc func didPressAddListButton(_ sender: UIButton) {
        let newList = List(name: "", color: .systemBlue)
        let viewController = ListViewController(list: newList) { [weak self] list in
            self?.add(list: list)
            self?.updateSnapshot()
            self?.dismiss(animated: true)
        }
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didPressCancel(_:)))
        viewController.navigationItem.title = NSLocalizedString("Add List", comment: "Add list title")
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
@objc func didPressAddReminderButton(_ sender: UIButton) {
        guard let list = ReminderStore.shared.getDefaultListForReminder() else { return }
        let reminder = Reminder(title: "", dueDate: Date.now, list: list)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.add(reminder: reminder)
            self?.updateSnapshot(reloading: [reminder.list.id])
            self?.dismiss(animated: true)
        }
        viewController.isAddingNewReminder = true
        viewController.setEditing(true, animated: true)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelAddingReminder(_:)))
        viewController.navigationItem.title = NSLocalizedString("Add Reminder", comment: "Add reminder view controller title")
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    @objc func didCancelAddingReminder(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
