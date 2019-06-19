//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Stephen Jenks on 5/9/19.
//  Copyright © 2019 Stephen Jenks. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    var defaultBackgroundColor : UIColor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded category view controller")
        loadCategories()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if let color = defaultBackgroundColor {
//            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
//            navBar.barTintColor = color
//            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.flatWhite]
//
//        } else {
//            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")}
//            defaultBackgroundColor = navBar.barTintColor    // save the nav bar color
//        }
//        tableView.reloadData()
//    }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = categories?.count ?? 1
        if count < 1 {
            count = 1
        }
//        print("category count is \(count)")
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        var categoryName = "No Categories Added"
        var category : Category? = nil
        let color = UIColor(randomFlatColorOf:.light)
        var colorString = color.hexValue()
        if let categoryCount = categories?.count {
            if categoryCount > indexPath.row {  // so we have enough
                category = categories?[indexPath.row]
                categoryName = category?.name ?? categoryName
                colorString = category?.bgColor ?? colorString
                //print("category color is \(colorString)")
            }
        }
        //print("color for row \(indexPath.row) is \(colorString)")
        cell.textLabel?.text = categoryName
        cell.backgroundColor = UIColor(hexString: colorString)
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category : Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving categories \(error)")
        }
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData();
    }

    //MARK: - delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
//            print("Deleting category \(categoryForDeletion)")
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Failed to delete category, \(error)")
            }
//            tableView.reloadData()
        }
    }
 
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() // place to save the text field from the closure
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // what happens when user clicks button
            if (textField.text != nil && textField.text!.count > 0) {
                
                let newCategory = Category()
                newCategory.name = textField.text!;
                var color = UIColor(randomFlatColorOf:.light)
                var colorIsDark = true
                var colorString = color.hexValue()
                repeat {    // loop until it is a lightish color
                    var hexString = colorString
                    hexString.remove(at: hexString.startIndex)
                    let num : Int = Int(hexString, radix: 16) ?? 0
//                    print("num is \(num)")
                    let red = num >> 16
                    let green = (num >> 8) & 0xff
                    let blue = num & 0xff
                    if red < 100 || green < 100 || blue < 100 {
                        color = UIColor(randomFlatColorOf:.light)
                        colorString = color.hexValue()
                    } else {
                        colorIsDark = false
                    }
                } while (colorIsDark)
//                print("color is \(colorString)")

                newCategory.bgColor = colorString
                self.save(category: newCategory)
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category";
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row < categories?.count ?? 0) {
            performSegue(withIdentifier: "goToItems", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}
