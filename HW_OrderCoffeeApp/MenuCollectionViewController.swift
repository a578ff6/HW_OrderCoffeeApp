//
//  MenuCollectionViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

import UIKit
import FirebaseFirestore


private let reuseIdentifier = "CategoryCell"

class MenuCollectionViewController: UICollectionViewController {
    
    struct PropertyKeys {
        static let categoryToDrinksSegue = "CategoryToDrinksSegue"
    }
    
    
    var categories: [Category] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategoriesFromFirestore()
        collectionView.collectionViewLayout = CollectionViewLayoutProvider.generateGridLayout()

    }
    
    
    func loadCategoriesFromFirestore() {
        let db = Firestore.firestore()
        db.collection("Categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.categories = snapshot?.documents.compactMap({ document in
                    try? document.data(as: Category.self)
                }) ?? []
                
                self.collectionView.reloadData()
            }
        }
    }
    

    // MARK: - UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
            fatalError("Cannot create CategoryCollectionViewCell")
        }
    
        let category = categories[indexPath.row]
        cell.update(with: category)
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.categoryToDrinksSegue,
           let destinationVC = segue.destination as? DrinksCategoryCollectionViewController,
           let indexPath = collectionView.indexPathsForSelectedItems?.first {
            let selectedCategory = categories[indexPath.row]
            destinationVC.categoryId = selectedCategory.id
        }
    }
    
}


