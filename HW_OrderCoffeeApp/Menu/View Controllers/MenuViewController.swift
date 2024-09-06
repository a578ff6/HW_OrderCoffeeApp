//
//  MenuViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/31.
//

/*
 ## MenuViewController：
 
    - 負責顯示飲品的分類頁面和網站橫幅，並處理用戶在這些視圖中的互動。透過 MenuView 來設置視圖，並使用 MenuCollectionHandler 來管理 UICollectionView 的資料顯示與用戶互動。

    * 使用的自定義視圖：
        - MenuView 包含一個 UICollectionView，用來顯示不同的飲品分類和網站橫幅。

    * 數據處理：
        - MenuCollectionHandler 負責管理 UICollectionView 的資料顯示及用戶互動，包括處理飲品分類和網站橫幅的顯示邏輯。
        - 當網站橫幅被點擊時，WebsiteImageCell 透過代理模式通知 MenuViewController 打開對應的網頁連結。

    * 主要流程：
        - loadView：
            在 loadView 中，將控制器的主視圖設置為自定義的 MenuView 。
 
        - viewDidLoad:
            在 viewDidLoad 方法中，設置 UICollectionView 的 dataSource 和 delegate，並從後端加載飲品分類和網站橫幅資料。
            加載完成後，將資料傳遞給 MenuCollectionHandler 來顯示於 UICollectionView 中。
 
        - prepare(for:sender:)：
            當用戶點擊某個飲品分類時，使用此方法將選中的分類資料傳遞給下一個視圖控制器，進行詳細顯示。

        - openWebsite(url:)：
            當用戶點擊網站橫幅時，MenuViewController 透過此方法接收點擊事件，並彈出確認對話框，詢問用戶是否打開連結。若用戶確認，即打開對應的網頁。

 */


// MARK: - 已完善

import UIKit

/// 負責顯示飲品分類頁面、網站橫幅的視圖控制器。
class MenuViewController: UIViewController {

    // MARK: - Properties
    
    private let menuView = MenuView()
    private let collectionHandler = MenuCollectionHandler()
    
    /// 定義 Menu 頁面的不同 section
    enum MenuSection: Int, CaseIterable {
        case websiteBanner // 顯示網站橫幅
        case drinkCategories // 顯示飲品分類
    }
    
    // 用來追踪網站和分類資料是否加載完成。
    private var isWebsiteLoaded = false
    private var isCategoriesLoaded = false

    // MARK: - Lifecycle Methods

    override func loadView() {
        view = menuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        HUDManager.shared.showLoading(in: self.view, text: "Loading...")
        loadWebsites()
        loadCategories()
    }

    
    // MARK: - Setup Methods
    
    /// 配置 UICollectionView 的 dataSource、delegate，並註冊自定義的單元格類別。
    private func setupCollectionView() {
        menuView.collectionView.dataSource = collectionHandler
        menuView.collectionView.delegate = collectionHandler
        menuView.collectionView.register(WebsiteImageCell.self, forCellWithReuseIdentifier: WebsiteImageCell.reuseIdentifier)
        menuView.collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        menuView.collectionView.register(MenuSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MenuSectionHeaderView.headerIdentifier)
        collectionHandler.delegate = self        // 將 MenuViewController 設置為 delegate，以便處理導航
    }

    
    // MARK: - Data Loading
 
    /// 加載網站橫幅資料，並將資料傳遞給 collectionHandler 來顯示於 UICollectionView 中。
    private func loadWebsites() {
        WebsiteManager.shared.loadWebsites { [weak self] result in
            switch result {
            case .success(let websites):
                self?.collectionHandler.websites = websites
                self?.isWebsiteLoaded = true
                self?.checkIfAllDataLoaded()
                self?.menuView.collectionView.reloadData()
            case .failure(let error):
                print("Error loading websites: \(error)")
                self?.isWebsiteLoaded = true
                self?.checkIfAllDataLoaded()
            }
        }
    }
    
    /// 加載飲品分類資料，並將資料傳遞給 collectionHandler 來顯示於 UICollectionView 中。
    private func loadCategories() {
        MenuController.shared.loadCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.collectionHandler.categories = categories
                    self?.isCategoriesLoaded = true
                    self?.checkIfAllDataLoaded()
                    self?.menuView.collectionView.reloadData()
                case .failure(let error):
                    print("Error loading categories: \(error)")
                    AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self!)
                    self?.isCategoriesLoaded = true
                    self?.checkIfAllDataLoaded()
                }
            }
        }
    }
    
    /// 每次加載任務完成後都會來檢查所有數據是否都已加載，並在所有數據加載完成後隱藏 HUD。
    private func checkIfAllDataLoaded() {
        if isWebsiteLoaded && isCategoriesLoaded {
            HUDManager.shared.dismiss()
        }
    }
    
    // MARK: - Navigation
    
    /// 當用戶點擊某個分類時，將選中的分類資料傳遞給 DrinksCategoryCollectionViewController。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.categoryToDrinksSegue,
           let destinationVC = segue.destination as? DrinksCategoryViewController,

           let selectedCategory = sender as? Category {
            destinationVC.categoryId = selectedCategory.id
            destinationVC.categoryTitle = selectedCategory.title
        }
    }
    
    /// 打開指定的網站 URL。
    func openWebsite(url: URL) {
        AlertService.showAlert(withTitle: "打開連結", message: "確定要打開這個連結嗎？", inViewController: self, showCancelButton: true) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
