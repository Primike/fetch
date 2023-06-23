//
//  RecipesViewModel.swift
//  fetch
//
//  Created by Prince Avecillas on 6/21/23.
//

import Foundation

protocol RecipeViewModelDelegate: AnyObject {
    func didFinishFetch()
}

class RecipesViewModel {
    private let dataManager: RecipesDataManager
    private(set) var recipes = [Recipe]()
    private(set) var recipeSearch = [Recipe]()
    weak var delegate: RecipeViewModelDelegate?

    init(dataManager: RecipesDataManager) {
        self.dataManager = dataManager
    }
    
    func fetchData() {
        dataManager.getRecipesData(url: APIURL.recipes.value) { [weak self] (result) in
            guard let self = self, let delegate = self.delegate else { return }
            
            switch result {
            case .success(let data):
                self.recipes = data.meals
                self.recipeSearch = data.meals
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                delegate.didFinishFetch()
            }
        }
    }
    
    //MARK: Tableview Methods
    func getNumberOfRows() -> Int {
        return recipeSearch.count
    }
        
    func getRecipeID(for indexPath: IndexPath) -> String? {
        return recipeSearch[indexPath.row].id
    }

    //MARK: Compresses And Matches Texts
    func getSearchResults(searchText: String) {
        if searchText.isEmpty {
            recipeSearch = recipes
            return
        }
        
        let searchString = compressText(text: searchText)
        
        recipeSearch = recipes.filter({ recipe in
            let newText = compressText(text: recipe.name)
            
            return newText.contains(searchString)
        })
    }
    
    //MARK: Converts String Into An Alphanumerical, Lowercased, Spaceless String
    func compressText(text: String) ->  String {
        return text.lowercased().filter {
            ("a"..."z" ~= $0) || ("0"..."9" ~= $0)
        }
    }
    
    //MARK: Recipe Cell Methods
    func getCellName(for indexPath: IndexPath) -> String {
        return recipeSearch[indexPath.row].name
    }
    
    func getCellImageURL(for indexPath: IndexPath) -> String {
        return recipeSearch[indexPath.row].image
    }
}
