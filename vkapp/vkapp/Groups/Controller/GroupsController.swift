//
//  GroupsController.swift
//  VKApp
//
//  Created by Григорий Мартюшин on 24.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class GroupsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Outlets
    @IBOutlet weak var btnLogout: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: Properties
    var realmGroupsList: Results<RLMGroup>?
    var groupsList: [Group]?
    
    // Адаптер для получения данных
    let groupsAdapter = GroupsAdapter()
    
    // Список данных для отображения во вью
    var viewModels: [GroupViewModel] = []
    let viewFactory = GroupsViewFactory()
    
    // Рекомендованные групп
    var recommendedGroups = [Group]()
    
    var token: NotificationToken?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = NSLocalizedString("Groups", comment: "")
        
        btnLogout.title = NSLocalizedString("Logout", comment: "")
        btnLogout.tintColor = DefaultStyle.self.Colors.tint
        
        // Получаем группы через адаптер (ниже предыдущая реализация через замыкания и Realm)
        groupsAdapter.getGropus { [weak self] (groups) in
            guard let self = self else { return }
            self.groupsList = groups
            self.viewModels = self.viewFactory.constructViews(from: groups)
            self.tableView.reloadData()
        }
        
        // Подписываемся на изменение данных
//        subscribeToRealmChanges()
//
//        // Загрузка информации о группах
//        VKService.shared.getGroupsList { result in
//            switch result {
//            case let .success(groupsList):
//                do {
//                    for group in groupsList {
//                        try RealmService.save(items: group)
//                    }
//
//                } catch let err {
//                    self.showErrorMessage(message: err.localizedDescription)
//                }
//            case let .failure(err):
//                self.showErrorMessage(message: err.localizedDescription)
//            }
//        }
    }
    
    // MARK: Data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if let groupsList = self.groupsList {
                return groupsList.count
            } else {
                return 0
            }
        } else {
            return recommendedGroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath) as? GroupsCell else {
            preconditionFailure("Error")
        }
        
        if let _ = self.groupsList,
            indexPath.section == 1
        {
            cell.configure(with: viewModels[indexPath.row])
        } else {
            cell.configure(with: recommendedGroups[indexPath.row])
        }

        // Configure the cell...
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            if indexPath.section == 1,
//                let groupsList = self.groupsList,
//                let objectToDelete = groupsList.filter("groupId=\(groupsList[indexPath.row].groupId)").first
//            {
//
//                do {
//                    try RealmService.delete(object: objectToDelete)
//                } catch let err {
//                    self.showErrorMessage(message: err.localizedDescription)
//                }
//            } else {
//                return
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("Your groups", comment: "")
        } else {
            if recommendedGroups.count > 0 {
                return NSLocalizedString("Recomended groups", comment: "")
            } else {
                return ""
            }
        }
    }
    
    // MARK: Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if recommendedGroups.indices.contains(indexPath.row) {
                do {
                    let recomendedGroup = recommendedGroups[indexPath.row]
                    let realmRecomendedGroups = RLMGroup(groupId: recomendedGroup.groupId, name: recomendedGroup.name, image: recomendedGroup.imageString)
                    
                    try RealmService.save(items: realmRecomendedGroups)
                    recommendedGroups.remove(at: indexPath.row)
                    
                    tableView.reloadData()
                } catch let err {
                    self.showErrorMessage(message: err.localizedDescription)
                }
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
                return
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
    }
    
    // MARK: Cestom methods
    fileprivate func subscribeToRealmChanges () {
        do {
            self.realmGroupsList = try RealmService.get(RLMGroup.self).sorted(byKeyPath: "name", ascending: true)
            
            if let groups = self.realmGroupsList {
                // Подписываемся на изменения групп
                self.token = groups.observe { [weak self] (changes: RealmCollectionChange) in
                    guard let self = self else { return }
                    
                    switch changes {
                    case .initial(_), .update(_, _, _, _):
                        self.tableView.reloadData()
                        
                    case let .error(err):
                        self.showErrorMessage(message: err.localizedDescription)
                    }
                }
            }
            
        } catch let err {
            showErrorMessage(message: err.localizedDescription)
        }
    }
}

// MARK: Search bar delegate
extension GroupsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 2 {
            // Покажем кнопку отмены
            searchBar.showsCancelButton = true
            
            // Загрузка информации о группах
            VKService.shared.getGroupSearch(query: searchText) { result in
                switch result {
                case let .success(groups):
                    // Преобразуем [RLMGroup] -> [Group]
                    self.recommendedGroups = groups.compactMap { (group) in
                        Group(groupId: group.groupId, name: group.name, image: group.imageString)
                    }
                    
                    self.tableView.reloadData()
                case .failure(_):
                    break
                }
            }
        } else {
            if searchText.count == 0 {
                // Спрячем кнопку отмены
                searchBar.showsCancelButton = false
                recommendedGroups.removeAll()
            } else {
                // Покажем кнопку отмены
                searchBar.showsCancelButton = true
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.searchTextField.text {
            if searchText.count < 2 {
                showErrorMessage(message: "Для поиска необходимо минимум два символа")
            }
        }
        
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        searchBar.endEditing(true)

        // Спрячем кнопку отмены
        searchBar.showsCancelButton = false
        
        // Очищаем фильтрованный список
        recommendedGroups.removeAll()
        
        tableView.reloadData()
    }
}
