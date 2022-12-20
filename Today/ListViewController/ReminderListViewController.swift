/*
See LICENSE folder for this sample’s licensing information.
*/

import UIKit

class ReminderListViewController: UICollectionViewController {
    let list: List
    var dataSource: DataSource!
    var reminders: [Reminder] = []
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
    
    init(list: List) {
        self.list = list
        super.init(collectionViewLayout: ReminderListViewController.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAddButton()
        collectionView.backgroundColor = .todayGradientFutureBegin
        navigationController?.navigationBar.backgroundColor = .clear
        
        configureRegisterCell()
        configureRegisterSectionHeader()
        
        listStyleSegmentedControl.selectedSegmentIndex = listStyle.rawValue
        listStyleSegmentedControl.addTarget(self, action: #selector(didChangeListStyle(_:)), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentedControl
       
        updateSnapshot()
        
        collectionView.dataSource = dataSource
        collectionView.isUserInteractionEnabled = true
        setupLongPressGestureForCollectionViewCell()
        prepareReminderStore(withIdentifier: list.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshBackground()
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filteredReminders[indexPath.item].id
        showDetail(for: id)
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == ProgressHeaderView.elementKind, let progressView = view as? ProgressHeaderView else { return }
        progressView.progress = progress
    }
    
    func showDetail(for id: Reminder.ID) {
        let reminder = reminder(for: id)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.update(reminder, with: reminder.id)
            self?.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
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
    
    private func configureAddButton() {
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
        //apply contraints
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: widthMultiplier).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1).isActive = true //Aspect ratio 1:1
        // add button action
        button.addTarget(self, action: #selector(didPressAddButton(_:)), for: .touchUpInside)
        button.accessibilityLabel = NSLocalizedString("Add Reminder", comment: "Add reminder button accessibility label")
    }
    
    static private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
        
        let progressViewSupplementarySize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
        let progressViewSupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: progressViewSupplementarySize, elementKind: ProgressHeaderView.elementKind, alignment: .top)
        
        section.boundarySupplementaryItems = [progressViewSupplementaryItem]
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
    }
    
    private func configureRegisterCell() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
    
    private func configureRegisterSectionHeader() {
        let headerRegistration = UICollectionView.SupplementaryRegistration(elementKind: ProgressHeaderView.elementKind, handler: supplementaryRegistrationHandler)
        
        dataSource.supplementaryViewProvider = { supplementaryView, elementKind, indexPath in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] _, _, completion in
            self?.deleteReminder(with: id)
            self?.updateSnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func supplementaryRegistrationHandler(progressView: ProgressHeaderView, elmentKind: String, indexPath: IndexPath) {
        headerView = progressView
    }
    
    func configureAlertControllerForCell(at indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        let id = self.filteredReminders[indexPath.item].id
        let reminder = self.reminder(for: id)
        let editActionButton = UIAlertAction(title: "Edit", style: .default) { [weak self] action in
            let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
                self?.update(reminder, with: id)
                self?.updateSnapshot(reloading: [id])
            }
            viewController.setEditing(true, animated: true)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        alertController.addAction(editActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
            self?.deleteReminder(with: id)
            self?.updateSnapshot()
        }
        alertController.addAction(deleteActionButton)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelActionButton)
        self.present(alertController, animated: true)
    }
    
    func refreshBackground() {
        collectionView.backgroundView = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradientLayer(for: listStyle, in: collectionView.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        collectionView.backgroundView = backgroundView
    }
}

extension ReminderListViewController: UIGestureRecognizerDelegate {
    private func setupLongPressGestureForCollectionViewCell() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnCell(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.delaysTouchesBegan = true
        longPressGestureRecognizer.numberOfTapsRequired = 1
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        longPressGestureRecognizer.delegate = self
        self.collectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
}
