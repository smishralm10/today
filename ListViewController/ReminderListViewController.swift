/*
See LICENSE folder for this sample’s licensing information.
*/

import UIKit

class ReminderListViewController: UICollectionViewController {
    var dataSource: DataSource!
    var reminders: [Reminder] = Reminder.sampleData
    var listStyle: ReminderListStyle = .today
    var filteredReminders: [Reminder] {
        return reminders.filter{ listStyle.shouldInclude(date: $0.dueDate) }.sorted { $0.dueDate < $1.dueDate }
    }
    var listStyleSegmentedControl = UISegmentedControl(items: [ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name])
    var headerView: ProgressHeaderView?
    var progress: CGFloat {
        let chunkSize = 1.0 / CGFloat(filteredReminders.count)
        let progress = filteredReminders.reduce(0.0) { partialResult, reminder in
            let chunk  = reminder.isComplete ? chunkSize : 0
            return partialResult + chunk
        }
        return progress
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAddButton()
        collectionView.backgroundColor = .todayGradientFutureBegin
        navigationController?.navigationBar.backgroundColor = .clear
        
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        listStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue
        listStyleSegmentedControl.addTarget(self, action: #selector(didChangeListStyle(_:)), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentedControl
        
        let headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: ProgressHeaderView.elementKind, handler: supplementaryRegistrationHandler)
        
        dataSource.supplementaryViewProvider = { supplementaryView, elementKind, indexPath in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        updateSnapshot()
        
        collectionView.dataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshBackground()
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filteredReminders[indexPath.item].id
        shotDetail(for: id)
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == ProgressHeaderView.elementKind, let progressView = view as? ProgressHeaderView else { return }
        progressView.progress = progress
    }
    
    func shotDetail(for id: Reminder.ID) {
        let reminder = reminder(for: id)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.update(reminder, with: reminder.id)
            self?.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func configureAddButton() {
        let widthMultiplier = 0.15
        let button = UIButton(frame: .zero)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .todayPrimaryTint
        button.layer.cornerRadius = (view.bounds.width * widthMultiplier) / 2
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.backgroundColor = .todayAddButtonBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: widthMultiplier).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1).isActive = true //Aspect ration 1:1
        button.addTarget(self, action: #selector(didPressAddButton(_:)), for: .touchUpInside)
        button.accessibilityLabel = NSLocalizedString("Add Reminder", comment: "Add reminder button accessibility label")
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.headerMode = .supplementary
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete actin title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] _, _, completion in
            self?.deleteReminder(with: id)
            self?.updateSnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func refreshBackground() {
            collectionView.backgroundView = nil
            let backgroundView = UIView()
            let gradientLayer = CAGradientLayer.gradientLayer(for: listStyle, in: collectionView.frame)
            backgroundView.layer.addSublayer(gradientLayer)
            collectionView.backgroundView = backgroundView
        }
    
    private func supplementaryRegistrationHandler(progressView: ProgressHeaderView, elmentKind: String, indexPath: IndexPath) {
        headerView = progressView
    }
}


