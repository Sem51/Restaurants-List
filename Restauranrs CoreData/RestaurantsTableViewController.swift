//
//  RestaurantsTableViewController.swift
//  Restaraunts
//
//  Created by Семен Осипов on 09.11.16.
//  Copyright © 2016 Семен Осипов. All rights reserved.
//

import UIKit
import CoreData

class RestaurantsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    var restaurants: [Restaurant] = []
    var searchResult: [Restaurant] = []
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //установка белого цвета для тайтла
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        //самомасштабирование
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //Настройка SearchController
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search restaurants"
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResult.count
        } else {
            return restaurants.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let restaurant = (searchController.isActive) ? searchResult[indexPath.row] : restaurants[indexPath.row]
        
        cell.nameLabel?.text = restaurant.name
        
        cell.thumbrailImageView?.image = UIImage(data: restaurant.image as! Data)
        cell.thumbrailImageView?.layer.cornerRadius = 30
        cell.thumbrailImageView?.clipsToBounds = true
        
        cell.typeLabel?.text = restaurant.type
        cell.locationLabel?.text = restaurant.location
        
        cell.accessoryType = restaurant.isVisited ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let _newIndexPath = newIndexPath {
                tableView.insertRows(at: [_newIndexPath], with: .fade)
            }
        case .delete:
            if let _newIndexPath = newIndexPath {
                tableView.deleteRows(at: [_newIndexPath], with: .fade)
            }
        case .update:
            if let _newIndexPAth = newIndexPath {
                tableView.rectForRow(at: _newIndexPAth)
            }
        default:
            tableView.reloadData()
        }
        restaurants = controller.fetchedObjects as! [Restaurant]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Social
        let shareAction = UITableViewRowAction(style: .default, title: "Поделиться", handler: {
            (action, indexPath) -> Void in
            let defaultText = "Just checking in at " + self.restaurants[indexPath.row].name!
            let activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        })
        
        let deleteAction =  UITableViewRowAction(style: .default, title: "Удалить", handler: {
            (action, indexPath) -> Void in
            let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(self.restaurants[indexPath.row])
            (UIApplication.shared .delegate as! AppDelegate).saveContext()
            self.restaurants.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            do {
                self.restaurants = try context.fetch(Restaurant.fetchRequest())
            } catch {
                print("Fetching faild")
            }
            
            
        })
        shareAction.backgroundColor = UIColor.lightGray
        return [deleteAction, shareAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! DetailViewController
                //Настройка контроллера назначения
                destinationController.restaurant = (searchController.isActive) ? searchResult[indexPath.row] : restaurants[indexPath.row]
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.hidesBarsOnSwipe = true
        getData()
        tableView.reloadData()
    }
    
    @IBAction func unwindToRestaurants(segue: UIStoryboardSegue) {
        
    }
    
    //MARK: - Get Data from CoreData
    
    func getData() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        do {
            restaurants = try context.fetch(Restaurant.fetchRequest())
        } catch {
            print("Fetching faild")
        }
    }
    
    //MARK: - UISearchResultsUpdating protocol
    
    func updateSearchResults(for searchController: UISearchController) {
        if let SearchText = searchController.searchBar.text {
            filterContent(searchText: SearchText)
            tableView.reloadData()
        }
    }
    
    func filterContent(searchText: String) {
        searchResult = restaurants.filter(){(restaurant: Restaurant) -> Bool in
            let name = restaurant.name?.lowercased().range(of: searchText.lowercased())
            let location = restaurant.location?.lowercased().range(of: searchText.lowercased())
            return name != nil || location != nil
        }
    }
}
