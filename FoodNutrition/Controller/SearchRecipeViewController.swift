//
//  SearchRecipeViewController.swift
//  FoodNutrition
//
//  Created by Carolyn Pan on 12/8/21.
//

import UIKit
import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class SearchRecipeViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var arrRecipeInfo: [RecipeInfo] = [RecipeInfo]()
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tblView.delegate = self
//        self.tblView.dataSource = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            return
        }
        arrRecipeInfo.removeAll()
        getRecipesFromSearch(searchText)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRecipeInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let recipeKey = arrRecipeInfo[indexPath.row].key
        let recipeTitle = arrRecipeInfo[indexPath.row].title
                
        cell.textLabel?.text = "\(recipeKey), \(recipeTitle)"
        return cell
    }
    
    func getSearchURL(_ searchText: String) -> String {
        //print(recipeSearchURL + "apiKey=" + apiKey + "&query=" + searchText)
        return recipeSearchURL + "apiKey=" + apiKey + "&query=" + searchText
    }
    
    func getRecipesFromSearch(_ searchText: String) {
        let url = getSearchURL(searchText)
                        
        AF.request(url).responseJSON { response in
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
                    
            if response.data == nil {
                return
            }
                    
            let recipes = JSON(response.data!)
            for (_, recipe): (String, JSON) in recipes {
                let recipeInfo = RecipeInfo()
                recipeInfo.key = recipe["id"].stringValue
                recipeInfo.title = recipe["title"].stringValue
                recipeInfo.imageType = recipe["imageType"].stringValue
                
                print(recipe)
                
                self.arrRecipeInfo.append(recipeInfo)
            }
            self.tblView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipeInfo = arrRecipeInfo[indexPath.row]
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(recipeInfo, update: .modified)
            }
        }
        catch {
            print(error)
        }
        
        //print(recipeInfo)
            
        //once the selected recipe is added in the realm database, pop the view controller
        performSegue(withIdentifier: "showNavigation", sender: self)
        }
}
