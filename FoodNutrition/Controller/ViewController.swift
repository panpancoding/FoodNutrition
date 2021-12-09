//
//  ViewController.swift
//  FoodNutrition
//
//  Created by Carolyn Pan on 12/8/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var arrRecipeInfo: [RecipeInfo] = [RecipeInfo]()
    var arrNutrition: [Nutrition] = [Nutrition]()

    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadNutrition()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNutrition.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                
        let recipeName = arrRecipeInfo[indexPath.row].title
        let caloriesInfo = arrNutrition[indexPath.row].calories
        let carbsInfo = arrNutrition[indexPath.row].carbs
        let fatInfo = arrNutrition[indexPath.row].fat
        let protainInfo = arrNutrition[indexPath.row].protain
                
        cell.textLabel?.text = "\(recipeName), calories: \(caloriesInfo), carbs: \(carbsInfo), fat: \(fatInfo)"
        return cell
    }
    
    func loadNutrition() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        do {
            let realm = try Realm()
            let recipes = realm.objects(RecipeInfo.self)
            self.arrRecipeInfo.removeAll()
                
            self.arrRecipeInfo.append(contentsOf: recipes)
                
            getAllNutrition(Array(recipes)).done {nutrition in
                self.arrNutrition.append(contentsOf: nutrition)
                self.tblView.reloadData()
            }
            .catch {error in
                print(error)
                }
            } catch {
                print("Error in reading database\(error)")
            }
    }
    
    func getAllNutrition(_ recipes: [RecipeInfo]) -> Promise<[Nutrition]> {
                        
        var promises: [Promise<Nutrition>] = []
                        
        for i in 0 ..< recipes.count {
            promises.append(getNutrition(recipes[i].key))
        }
        return when(fulfilled: promises)
    }
    
    func getNutrition(_ key: String) -> Promise<Nutrition> {
        return Promise<Nutrition> { seal -> Void in
            let url = recipeNutritionURL + key + "/nutritionWidget.json?apiKey=" + apiKey
            //print()
            AF.request(url).responseJSON { response in
                               
                if response.error != nil {
                    seal.reject(response.error!)
                }
                   
                let nutritionInfo = JSON(response.data!)
                //print(nutritionInfo)
                let nutrition = Nutrition()
                nutrition.calories = nutritionInfo["calories"].stringValue
                nutrition.carbs = nutritionInfo["carbs"].stringValue
                nutrition.fat = nutritionInfo["fat"].stringValue
                nutrition.fat = nutritionInfo["protein"].stringValue
                seal.fulfill(nutrition)
            }
        }
    }
}

