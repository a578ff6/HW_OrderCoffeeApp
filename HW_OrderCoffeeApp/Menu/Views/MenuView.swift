//
//  MenuView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//

// MARK: - 筆記
/*
 ## MenuView：
 
    - 定義並管理菜單頁面的視圖結構，主要使用 UICollectionView 來顯示飲品分類和網站橫幅的內容。

    * 佈局設置：
        - setupView 方法負責將 UICollectionView 添加到視圖 (MenuView) 中，並設置其佈局約束。

    * 主要結構：
        - createCollectionView 方法用來創建並配置 UICollectionView，設定不同的佈局以顯示不同的 section 內容。
        - 在 setupView 方法中，將 UICollectionView 添加到主視圖，並透過 NSLayoutConstraint 設定其佈局約束，以確保 UICollectionView 正確填滿整個視圖。
 
 */


// MARK: - 已完善
import UIKit

/// 定義並管理菜單頁面的主要視圖，使用 UICollectionView 來顯示「飲品的分類」及「網站橫幅」。
class MenuView: UIView {
    
    // MARK: - UI Elements

    /// UICollectionView，用於顯示不同 section 的內容，如網站橫幅和飲品分類。
    let collectionView = MenuView.createCollectionView()
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods

    /// 配置主視圖，將 UICollectionView 添加到視圖並設置其約束。
    private func setupView() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    /// 建立並配置 UICollectionView，使用不同的佈局來顯示不同的 section。
    /// - Returns: 已配置好的 UICollectionView。
    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = MenuViewController.MenuSection(rawValue: sectionIndex) else {
                return nil
            }
            return MenuLayoutProvider().generateLayout(for: section)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }
    
}



