//
//  HomeViewController.swift
//  Today
//
//  Created by Shreyansh Mishra on 17/12/22.
//

import UIKit

class HomeViewController: UICollectionViewController {
    var dataSource: DataSource!
    var lists: [List] = []
    var reminders: [Reminder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("My Lists", comment: "home viewcontroller title")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = editButtonItem
        
        collectionView.collectionViewLayout = createListLayout()
        collectionView.dataSource = dataSource
        registerCellWithDataSource()
        prepareReminderStore()
        updateSnapshot()
        configureFloatingButtons()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let list = lists[indexPath.item]
        let reminderListViewController = ReminderListViewController(list: list)
        navigationController?.pushViewController(reminderListViewController, animated: true)
    }
    
    private func createListLayout() -> UICollectionViewCompositionalLayout {
        var listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfig.showsSeparators = true
        listConfig.trailingSwipeActionsConfigurationProvider = trailingSwipeActionsConfigurationProvider
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }
    
    private func trailingSwipeActionsConfigurationProvider(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completion in
            guard let self = self else { return }
            
            let identifier = self.dataSource.itemIdentifier(for: indexPath)
            
            guard let identifier = identifier else { return }

            if self.reminderCounts(for: identifier) > 0 {
                self.presentConfirmDeleteAlert(for: identifier)
            } else {
                self.deleteList(with: identifier)
            }
            completion(true)
        }
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActionConfig
    }
    
    private func registerCellWithDataSource() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    func showError(_ error: Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error alert title")
        let alertController = UIAlertController(title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("Ok", comment: "Alert ok button title")
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        present(alertController, animated: true)
    }
    
    private func configureFloatingButtons() {
        let addListButtonMultiplier = 0.15
        let addListButton = CircularButton(ofWidth: view.bounds.width * addListButtonMultiplier)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        addListButton.setImage(image, for: .normal)
        addListButton.tintColor = .white
        addListButton.backgroundColor = .todayPrimaryTint
        addListButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addListButton)
        // apply constraints
        addListButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        addListButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        addListButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: addListButtonMultiplier).isActive = true
        addListButton.heightAnchor.constraint(equalTo: addListButton.widthAnchor, multiplier: 1).isActive = true //Aspect ratio 1:1
        //add list action
        addListButton.addTarget(self, action: #selector(didPressAddListButton(_:)), for: .touchUpInside)
        
        let addReminderButtonMultiplier = 0.1
        let addReminderButton = CircularButton(ofWidth: view.bounds.width * addReminderButtonMultiplier)
        let reminderButtonImageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let reminderButtonImage = UIImage(systemName: "pencil", withConfiguration: reminderButtonImageConfig)
        addReminderButton.setImage(reminderButtonImage, for: .normal)
        addReminderButton.tintColor = .todayPrimaryTint
        addReminderButton.backgroundColor = .todayAddButtonBackground
        addReminderButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addReminderButton)
        // apply constraints
        addReminderButton.centerXAnchor.constraint(equalTo: addListButton.centerXAnchor).isActive = true
        addReminderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: addReminderButtonMultiplier).isActive = true
        addReminderButton.heightAnchor.constraint(equalTo: addReminderButton.widthAnchor, multiplier: 1).isActive = true // Aspect ration 1:1
        addReminderButton.bottomAnchor.constraint(equalTo: addListButton.topAnchor, constant: -20).isActive = true
        addReminderButton.addTarget(self, action: #selector(didPressAddReminderButton(_:)), for: .touchUpInside)
    }
    
    func presentConfirmDeleteAlert(for id: List.ID) {
        let list = list(for: id)
        let alertController = UIAlertController(title: "Delete list \"\(list.name)\"?", message: "This will delete all reminders in the list", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] alertAction in
            self?.deleteList(with: id)
            self?.updateSnapshot()
            self?.dismiss(animated: true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true)
    }
}
