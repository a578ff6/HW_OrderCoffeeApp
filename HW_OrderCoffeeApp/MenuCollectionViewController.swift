//
//  MenuCollectionViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

import UIKit
import FirebaseFirestore
import Kingfisher

private let reuseIdentifier = "CategoryCell"

class MenuCollectionViewController: UICollectionViewController {
    
    
    var categories: [Category] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategoriesFromFirestore()
        collectionView.collectionViewLayout = generateGridLayout() 
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
    
    
    /// 生成網格布局
    func generateGridLayout() -> UICollectionViewLayout {
        /// 設定元素的間距
        let padding: CGFloat = 20
        
        /// 創建佈局項目
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        /// 創建水平布局群組
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/4)), subitem: item, count: 2)
        
        // 為群組設置間距和內邊距
        group.interItemSpacing = .fixed(padding)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding)
        
        // 用這個群組創建一個NSCollectionLayoutSection，設置群組間的間距，並調整上下的內邊距。
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        section.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: 0, bottom: padding, trailing: 0)
        
        // 回傳基於這個新部分的 UICollectionViewCompositionalLayout
        return UICollectionViewCompositionalLayout(section: section)
        
    }
    

    // MARK: - UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
    
        let category = categories[indexPath.row]
        cell.update(with: category)
        
        return cell
    }

}

