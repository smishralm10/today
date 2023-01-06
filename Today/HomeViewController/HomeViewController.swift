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
        
        collectionView.collectionViewLayout = createListLayout()
        collectionView.dataSource = dataSource
        registerCellWithDataSource()
        prepareReminderStore()
        updateSnapshot()
        configureFloatingButtons()
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
        return UICollectionViewCompositionalLayout.list(using: listConfig)
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
}
