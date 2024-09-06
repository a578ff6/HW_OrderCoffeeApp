//
//  MenuCollectionHandler.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//

/*
 ## MenuCollectionHandler：
 
    - 作為 UICollectionView 的 dataSource 和 delegate，負責處理資料的顯示及用戶的點擊操作。

    * 代理設置：
        - 使用 weak var delegate: MenuViewController? 來通知 MenuViewController 進行導航操作和其他需要控制器處理的事件，例如點擊分類後的視圖切換。

    * 主要流程：
        - UICollectionViewDataSource：
            負責處理 UICollectionView 中資料的顯示邏輯。根據 MenuViewController.MenuSection 來配置每個 section 的 cell。
            當顯示網站橫幅時，將網站資料傳遞給 WebsiteCollectionViewCell 並配置其顯示內容。
            當顯示飲品分類時，將分類資料傳遞給 CategoryCollectionViewCell 並配置其顯示內容。
 
        - UICollectionViewDelegate：
            當用戶點擊某個飲品分類時，觸發 MenuViewController 的 performSegue 方法，將選中的分類資料傳遞給下一個視圖控制器。
            當用戶點擊某個網站橫幅時，透過 WebsiteCollectionViewCellDelegate 將事件傳遞給 MenuViewController，由控制器決定是否打開對應的網站連結。
 */

// MARK: - 已完善

import UIKit

/// 處理 Menu 頁面的 UICollectionView dataSource 和 delegate 邏輯。
class MenuCollectionHandler: NSObject {

    // MARK: - Properties

    /// 儲存分類資料
    var categories: [Category] = []
    /// 儲存網站橫幅資料
    var websites: [Website] = []
    /// 代理，用來通知 MenuViewController 處理導航操作
    weak var delegate: MenuViewController?
    
}

// MARK: - UICollectionViewDataSource
extension MenuCollectionHandler: UICollectionViewDataSource {
    
    /// 設定 section 的數量，根據 MenuSection 的數量來決定。
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MenuViewController.MenuSection.allCases.count
    }
    
    /// 設定每個 section 中的 item 數量。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = MenuViewController.MenuSection(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .websiteBanner:
//            print("Websites count: \(websites.count)")
            return websites.count
        case .drinkCategories:
            return categories.count     // 飲品分類 section 中的項目數量
        }
    }
    
    /// 配置並返回對應的 UICollectionViewCell。
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = MenuViewController.MenuSection(rawValue: indexPath.section) else { fatalError("Invalid section")}
        
        switch sectionType {
        case .websiteBanner:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WebsiteImageCell.reuseIdentifier, for: indexPath) as? WebsiteImageCell else {
                fatalError("Cannot create WebsiteImageCell")
            }
            let website = websites[indexPath.item]
            if let url = URL(string: website.imagePath) {
                cell.configure(with: url) // 配置橫幅圖片
            }
            return cell
            
        case .drinkCategories:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
                fatalError("Cannot create CategoryCollectionViewCell")
            }
            let category = categories[indexPath.row]
            // 配置飲品分類的 cell，傳遞分類資料
            cell.update(with: category)
            return cell
        }
    }
    
    /// 配置並返回對應的 UICollectionReusableView 作為 section header。
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected element kind")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MenuSectionHeaderView.headerIdentifier, for: indexPath) as! MenuSectionHeaderView
        
        let section = MenuViewController.MenuSection(rawValue: indexPath.section)
        let title: String
        switch section {
        case .websiteBanner:
            title = "Latest News"
        case .drinkCategories:
            title = "Drink Menu"
        default:
            title = ""
        }
        
        headerView.configure(with: title)
        return headerView
    }
    
}

// MARK: - UICollectionViewDelegate
extension MenuCollectionHandler: UICollectionViewDelegate {
    
    /// 處理使用者點擊事件，根據 section 來區分處理邏輯。
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = MenuViewController.MenuSection(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .websiteBanner:
            if let cell = collectionView.cellForItem(at: indexPath) as? WebsiteImageCell {
                cell.addScaleAnimation() // 添加縮放動畫
            }
            // 立即執行 segue
            let selectedWebsite = websites[indexPath.item]
            if let url = URL(string: selectedWebsite.url) {
                delegate?.openWebsite(url: url) // 通知 MenuViewController 打開對應的網站連結
            }
            
        case .drinkCategories:
            if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
                cell.addScaleAnimation(duration: 0.15, scale: 0.85) {
                    // 動畫完成後執行 segue
                    let selectedCategory = self.categories[indexPath.item]
                    self.delegate?.performSegue(withIdentifier: Constants.Segue.categoryToDrinksSegue, sender: selectedCategory)
                }
            }
        }
    }

}
