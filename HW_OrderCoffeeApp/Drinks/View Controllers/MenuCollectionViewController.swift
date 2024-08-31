//
//  MenuCollectionViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

/*
 1. Storyboard 設置：
        - 在 storyboard 中添加一個 segue，從 MenuCollectionViewController 的 Collection View Cell 到 DrinksCategoryCollectionViewController。
          將 segue 的 id 設置為 "CategoryToDrinksSegue"。
 
 2. 程式碼：
        - 在 MenuCollectionViewController 中配置 segue 和 cell 的點擊事件。
 
 3. 配置：
        - Cell：傅哲顯示數據的視圖。
        - LayoutProvider：負責創建和配置 UICollectionView 的佈局。
        - Controller： 負責視圖控制器的邏輯，包括數據加載、使用者交互和導航。
 */

// MARK: - 程式碼處理部分

/*
 import UIKit
 import FirebaseFirestore

 private let categoryCellReuseIdentifier = "CategoryCell"

 /// 菜單頁面，顯示Category的飲品
 class MenuCollectionViewController: UICollectionViewController {
     
     @IBOutlet weak var MenuCollectionView: UICollectionView!
     
     // var userDetails: UserDetails?
     
     struct PropertyKeys {
          /// 轉場ID，segue 到 DrinksCategoryCollectionViewController。
          static let categoryToDrinksSegue = "CategoryToDrinksSegue"
      }
     
      /// 用於存儲從 Firestore 加載的類別
      var categories: [Category] = []
      
      let layoutProvider = MenuLayoutProvider()
     
      override func viewDidLoad() {
          super.viewDidLoad()
          loadCategories()       // 加載類別數據
          
          // 設置 Collection View 的佈局
          MenuCollectionView.collectionViewLayout = layoutProvider.generateGridLayout()
          MenuCollectionView.dataSource = self
          MenuCollectionView.delegate = self
          
          // 註冊自定義的 cell
          MenuCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
      }
      
     // MARK: - Data Loading

      /// 從 Firestore 加載類別數據。
      func loadCategories() {
          HUDManager.shared.showLoading(in: view, text: "Loading...")
          // 加載類別數據
          MenuController.shared.loadCategories { [weak self] result in
              DispatchQueue.main.async {
                  HUDManager.shared.dismiss()
                  switch result {
                  case .success(let categories):
                      self?.categories = categories
                      self?.MenuCollectionView.reloadData()
                  case .failure(let error):
                      print("Error loading categories: \(error)")
                      AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self!)
                  }
              }
          }
      }
     
 }


 // MARK: - UICollectionViewDataSource
 extension MenuCollectionViewController {
     
     /// 返回集合視圖中的項目數量。
     override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return categories.count
     }
     
     /// 為每個集合視圖項目提供一個配置好的單元格。
     override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCollectionViewCell else {
             fatalError("Cannot create CategoryCollectionViewCell")
         }
         
         let category = categories[indexPath.row]
         cell.update(with: category)
         
         return cell
     }
 }

 // MARK: - Navigation

 extension MenuCollectionViewController {
     
     /// 點擊 cell 時觸發 segue
     override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         performSegue(withIdentifier: PropertyKeys.categoryToDrinksSegue, sender: indexPath)
     }
     
     /// 為 segue 傳遞數據
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == PropertyKeys.categoryToDrinksSegue,
            let destinationVC = segue.destination as? DrinksCategoryCollectionViewController,
            let indexPath = MenuCollectionView.indexPathsForSelectedItems?.first {
             let selectedCategory = categories[indexPath.row]
             destinationVC.categoryId = selectedCategory.id
             destinationVC.categoryTitle = selectedCategory.title
         }
     }
     
 }
*/


// MARK: - 程式碼處理部分(修改用)


import UIKit
import FirebaseFirestore

private let categoryCellReuseIdentifier = "CategoryCell"

/// 菜單頁面，顯示Category的飲品
class MenuCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var MenuCollectionView: UICollectionView!
    
    // var userDetails: UserDetails?
    
    struct PropertyKeys {
         /// 轉場ID，segue 到 DrinksCategoryCollectionViewController。
         static let categoryToDrinksSegue = "CategoryToDrinksSegue"
     }
    
     /// 用於存儲從 Firestore 加載的類別
     var categories: [Category] = []
     
     let layoutProvider = MenuLayoutProvider()
    
     override func viewDidLoad() {
         super.viewDidLoad()
         loadCategories()       // 加載類別數據
         
         // 設置 Collection View 的佈局
         MenuCollectionView.collectionViewLayout = layoutProvider.generateGridLayout()
         MenuCollectionView.dataSource = self
         MenuCollectionView.delegate = self
         
         // 註冊自定義的 cell
         MenuCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: categoryCellReuseIdentifier)
     }
     
    // MARK: - Data Loading

     /// 從 Firestore 加載類別數據。
     func loadCategories() {
         HUDManager.shared.showLoading(in: view, text: "Loading...")
         // 加載類別數據
         MenuController.shared.loadCategories { [weak self] result in
             DispatchQueue.main.async {
                 HUDManager.shared.dismiss()
                 switch result {
                 case .success(let categories):
                     self?.categories = categories
                     self?.MenuCollectionView.reloadData()
                 case .failure(let error):
                     print("Error loading categories: \(error)")
                     AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self!)
                 }
             }
         }
     }
    
}


// MARK: - UICollectionViewDataSource
extension MenuCollectionViewController {
    
    /// 返回集合視圖中的項目數量。
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    /// 為每個集合視圖項目提供一個配置好的單元格。
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCollectionViewCell else {
            fatalError("Cannot create CategoryCollectionViewCell")
        }
        
        let category = categories[indexPath.row]
        cell.update(with: category)
        
        return cell
    }
}

// MARK: - Navigation

extension MenuCollectionViewController {
    
    /// 點擊 cell 時觸發 segue
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: PropertyKeys.categoryToDrinksSegue, sender: indexPath)
    }
    
    /// 為 segue 傳遞數據
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.categoryToDrinksSegue,
           let destinationVC = segue.destination as? DrinksCategoryCollectionViewController,
           let indexPath = MenuCollectionView.indexPathsForSelectedItems?.first {
            let selectedCategory = categories[indexPath.row]
            destinationVC.categoryId = selectedCategory.id
            destinationVC.categoryTitle = selectedCategory.title
        }
    }
    
}

