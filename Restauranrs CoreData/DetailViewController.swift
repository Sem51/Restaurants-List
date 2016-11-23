//
//  DetailViewController.swift
//  Restaraunts
//
//  Created by Семен Осипов on 10.11.16.
//  Copyright © 2016 Семен Осипов. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var rateButton: UIButton!
    
    var restaurant: Restaurant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantImageView.image = UIImage(data: restaurant.image as! Data)
        title = restaurant.name
        
        //Самомасштабирование
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if let rating = restaurant.rating, rating != "" {
            rateButton.setImage(UIImage(named: restaurant.rating!), for: UIControlState.normal)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantCustomTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = NSLocalizedString("Name", comment: "Name field")
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = NSLocalizedString("Type", comment: "Type field")
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = NSLocalizedString("Location", comment: "Location field")
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = NSLocalizedString("Been here", comment: "Been here field")
            cell.valueLabel.text = (restaurant.isVisited) ? NSLocalizedString("Yes", comment: "Yes answer") : NSLocalizedString("No", comment: "No answer")
        case 4:
            cell.fieldLabel.text = NSLocalizedString("Phone", comment: "Phone field")
            if let phone = restaurant.phoneNumber {
                cell.valueLabel.text = phone
            } else {
                cell.valueLabel.text = NSLocalizedString("no phone number", comment: "no phone number field")
            }
            cell.valueLabel.text = restaurant.phoneNumber
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3 {
            
            let optionMenu = UIAlertController(title: nil, message: "Что вы хотите сделать?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let isVisitedAction: UIAlertAction!
            
            if self.restaurant.isVisited {
                isVisitedAction = UIAlertAction(title:  "Я тут не был", style: .default, handler: {
                    (action: UIAlertAction!) -> Void in
                    self.restaurant.isVisited = false
                })
            } else {
                isVisitedAction = UIAlertAction(title:  "Я был здесь", style: .default, handler: {
                    (action: UIAlertAction!) -> Void in
                    self.restaurant.isVisited = true
                })
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantCustomTableViewCell
            cell.valueLabel.text = (restaurant.isVisited) ? "Yes" : "No"
            optionMenu.addAction(cancelAction)
            optionMenu.addAction(isVisitedAction)
            self.present(optionMenu, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {
        if let rateVC = segue.source as? RateViewController {
            if let rating = rateVC.rating {
                rateButton.setImage(UIImage(named: rating), for: UIControlState.normal)
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                restaurant.rating = rating
                do {
                    try context.save()
                } catch {
                    print(error)
                    return
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMap" {
            let destinationViewController = segue.destination as! MapViewController
            destinationViewController.restaurant = restaurant
        }
    }
    
    @IBAction func callToRestaurant(_ sender: Any) {
        
        if restaurant.phoneNumber != nil {
            let optionMenu = UIAlertController(title: nil, message: "Вы хотите совершить звонок?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let callActionHandler = {(acton: UIAlertAction) -> Void in
                let alertMessage = UIAlertController(title: "Сервис недоступен", message: "Простите, но сейчас позвонить невозможно. Позвоните позже.", preferredStyle: .alert)
                alertMessage.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                self.present(alertMessage, animated: true, completion: nil)
            }
            
            let callAction = UIAlertAction(title: "Call " + "\(restaurant.phoneNumber!)", style: .default, handler: callActionHandler)
            
            optionMenu.addAction(cancelAction)
            optionMenu.addAction(callAction)
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertController(title: "Невозможно выполнить операцию", message: "Не указан номер телефона для данного ресторана", preferredStyle: .alert)
            let button = UIAlertAction(title: "Ok", style: .default, handler: nil)
            errorAlert.addAction(button)
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
}
