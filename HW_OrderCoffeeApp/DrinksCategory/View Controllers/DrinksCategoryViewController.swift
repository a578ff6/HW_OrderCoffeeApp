//
//  DrinksCategoryViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/4.
//

/*
 ## DrinksCategoryViewController：
 
    - 功能：顯示特定類別下的飲品，並允許用戶在「網格」與「列」佈局之間切換。
    - 視圖設置：透過 DrinksCategoryView 設置視圖，並使用 DrinksCategoryHandler 管理 UICollectionView 的資料顯示及用戶互動。
    - 數據加載與佈局：飲品數據從 Firestore 加載，並在加載完成後自動調用 prepareLayouts()，動態生成正確的佈局。
 
    * 使用的自定義視圖：
        - DrinksCategoryView 包含一個 UICollectionView，用於顯示不同子類別中的飲品。
 
    * 數據處理：
        - DrinksCategoryHandler 管理 UICollectionView 的資料顯示及用戶互動，包括處理飲品的顯示邏輯，並支援不同佈局的切換（網格和列）。
        - 當飲品數據從 Firestore 中加載完成後，將資料傳遞給 DrinksCategoryHandler，並更新 UICollectionView 顯示。
 
    * 主要流程：
        - loadView：
            設置 DrinksCategoryView 為主視圖。
        - viewDidLoad：
            設置 UICollectionView 的 dataSource 和 delegate，並從 Firestore 加載該類別的飲品數據。
            資料加載完成後，調用 prepareLayouts()，生成並應用佈局。
            設置切換按鈕，允許用戶在「網格」與「列」佈局間切換。
        - prepareLayouts：
            預先生成兩種佈局：網格和列表。透過 Layouts 字典，儲存這兩種佈局，在佈局切換時方便應用。
            並在「數據加載完成後」動態生成佈局以正確顯示項目。
        - loadDrinkForCategory：
            從 Firestore 加載飲品數據，成功後更新 DrinksCategoryHandler 的資料，並刷新 UICollectionView。
            資料加載成功後，自動調用 prepareLayouts()，確保佈局根據正確的數據生成。
        - switchLayoutsButtonTapped：
            用戶點擊切換佈局按鈕時，將在網格與列佈局之間進行切換，並且動態更新佈局和可見的項目，確保用戶體驗平順。
        - applyNewLayout：
            根據當前選擇的佈局 (activeLayout)，套用新的佈局，並更新右上角按鈕的圖示（網格或列表）。
            使用 reloadItems(at:) 來刷新當前可見的項目。
        - prepare(for segue:)：
            當點擊某個飲品項目，並進入詳細頁面時，透過 prepare(for segue:) 將選中的飲品資料傳遞給 DrinkDetailViewController。
 
    * 調整後的佈局切換：
        - 使用動態生成的佈局：
            相較於舊方式每次都重新生成佈局，現在是在數據加載成功後動態生成「網格」和「列」兩種佈局，並根據用戶選擇直接應用佈局，這樣可以確保佈局基於最新數據生成，並提高性能。
        - 局部刷新：
            使用 reloadItems(at:) 來僅刷新可見的項目，這樣的方式能保持動畫過渡效果，並且避免整體重繪，性能更佳，過渡更平滑。

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 使用 reloadData 和局部刷新的方式 (reloadItems(at:)) 之間的差異主要體現在性能和用戶體驗上。

 * reloadData 方法：
    - 整體刷新： reloadData 會刷新 UICollectionView 中的所有數據，不論當前可見的還是不可見的項目。
    - 性能影響： 如果數據量大，reloadData 的開銷會比較高，因為它會重新計算和重新繪製所有的 cell，即使這些 cell 可能在當前螢幕畫面上不可見。
    - 動畫丟失： 通常使用 reloadData 會丟失當前的過渡動畫，因為它會立即重繪所有項目，不考慮動畫效果。因此，我原先使用 reloadData 來切換佈局時，切換過程中的動畫效果沒有很平滑。
    - 體驗不連貫： 對於像切換佈局這樣的過渡操作，reloadData 會導致用戶感覺頁面突然全部更新，無法平滑過渡。

 * reloadItems(at:) 方法：
    - 局部刷新： reloadItems(at:) 只會刷新當前可見的 cell 和指定的 index paths，不會影響不可見的部分。
    - 性能更高： 由於只刷新了可見的項目，對性能的影響較小，能夠有效減少內存和計算資源的消耗，特別是當處理大量數據時。
    - 動畫保留： 使用 reloadItems(at:) 可以保持過渡動畫，尤其是當切換佈局時，可以讓切換過程變得更加平滑和自然。
    - 更好的用戶體驗： 因為只是局部刷新，過渡更平順，不會讓用戶感到頁面突然閃動或重新加載所有數據。

 * 總結：
    - reloadData： 適合在數據完全變更的情況下使用，比如需要重新加載完全不同的數據集，或者界面需要完全重繪。缺點是會刷新所有項目，對於較大量數據來說效率較低，動畫效果也不理想。
    - reloadItems(at:)： 適合局部更新，比如佈局切換或者某些項目更新的情況。這種方式能夠保留動畫效果，提升用戶體驗，並且對性能影響更小。

 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 ## 關鍵改進：
 
    * 提前準備佈局：
        - 我在 prepareLayouts() 中提前生成並存儲兩種佈局，這樣切換時不需要重新生成佈局，提升了切換效率。

    * 局部刷新可見項目：
        - 切換佈局後，通過 reloadVisibleItems() 僅刷新當前可見的項目，而不是整個 UICollectionView，這樣減少了多餘的刷新操作，使動畫過程更加流暢。

    * 動畫切換佈局：
        - 使用 setCollectionViewLayout(layout, animated: true) 方法在切換佈局時添加動畫，確保過渡平順。
 
    * 切記使用 debug View hierarchy 觀察滑動頁面後，佈局切換過程是否產生佈局堆疊問題！！（當初設置的順序有問題導致切換佈局使產生堆疊）！！！
 
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 ## 額外補充： https://reurl.cc/qvVA1y （對蘋果官方教材的研究）
 
    - 在切換佈局時使用了 UICollectionViewCompositionalLayout 和動畫來實現平順的佈局切換。

 # 關鍵步驟：

    * 提前定義兩種佈局並緩存它們：
        - 在 viewDidLoad() 方法中，使用 generateGridLayout() 和 generateColumnLayout() 兩個方法分別生成網格佈局和列佈局，並將它們存儲在一個 layout 字典中。
        - 這樣在切換佈局時，只需要從這個字典中取出已經定義好的佈局，並應用到 UICollectionView 中。

    * 切換佈局的動畫過程：
        - 當點擊切換佈局按鈕時，會根據當前的佈局（activeLayout）切換到另一個佈局，並使用 setCollectionViewLayout(layout, animated: true) 將新的佈局設置為 UICollectionView 的佈局。
        - 這個方法會自動提供過渡動畫，使佈局切換時看起來非常平順。
    
    * 局部刷新，而非整體重載：
        - 在佈局切換時，使用了 self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)，意味著它只會重新載入當前可見的項目，而不是重新加載整個集合視圖。
        - 這樣做可以減少重載數據的次數，提高動畫的平順度，並減少卡頓的可能性。

 # 分析：
 
    * 提前準備和緩存佈局：
        - 該範例在 App 啟動時已經定義了兩種佈局，並將它們保存在 `layout` 字典中。當用戶點擊按鈕時，會根據當前的佈局來快速切換，而不是重新生成佈局，這樣可以確保佈局切換的即時性和流暢性。
    
    * 局部刷新而非全局重載：
        - 通過僅刷新可見項目，確保切換時的渲染負擔較小，進而減少動畫卡頓的機會。這在數據量較大或佈局較複雜的情況下尤其有用。

    * 使用 Compositional Layout：
        - 支持複雜的佈局結構，可以通過組合來創建網格、列表等多種佈局，並且內建了支持動畫的功能，使切換過程更加順滑。

 # 應用到 DrinksCategoryViewController 中：

    * 提前定義和緩存兩種佈局：
        - 在 `DrinksCategoryViewController` 中提前定義並緩存 `grid` 和 `column` 佈局，減少在切換時重新生成佈局的時間。

    * 僅刷新可見的項目：
        - 在切換佈局時，避免使用 `reloadData()`。改為使用 `reloadItems(at:)`，只重新加載可見的項目來減少過度重載。

    * 使用 `setCollectionViewLayout(animated:)`：
        - 這個方法內建動畫效果，在切換佈局時使用它來確保過渡效果的平順。
 */

// MARK: - 已完善

import UIKit

/// 顯示特定類別下的飲品，並允許用戶在網格和列視圖之間切換。
class DrinksCategoryViewController: UIViewController {

    // MARK: - Properties

    private let drinksCategoryView = DrinksCategoryView()
    private let collectionHandler = DrinksCategoryHandler()
    private let layoutProvider = DrinksCategoryLayoutProvider()

    // 從上一個視圖控制器傳遞的類別ID、類別標題。
    var categoryId: String?
    var categoryTitle: String?
    
    /// 切換佈局的 Enum
    enum Layout {
        case grid, column
    }
    
    /// 儲存網格和列表的佈局設定
    private var layouts: [Layout: UICollectionViewLayout] = [:]
    
    /// 用來儲存目前的布局類型。預設為 .column。
    var activeLayout: Layout = .column {
        didSet {
            applyNewLayout()
        }
    }

    // MARK: - Lifecycle Methods
    override func loadView() {
        view = drinksCategoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupSwitchLayoutsButton()
        configureCollectionView()
        loadDrinkForCategory()            // 加載飲品資料，資料加載完畢後會調用 prepareLayouts
    }

    // MARK: - Setup Methods

    /// 設置 NavigationTitle
    private func setupNavigationTitle() {
        guard let title = categoryTitle else { return }
        self.navigationItem.title = title
    }
    
    /// 設置切換布局按鈕
    private func setupSwitchLayoutsButton() {
        let switchLayoutsButton = UIBarButtonItem(image: UIImage(systemName: "square.grid.2x2"), style: .plain, target: self, action: #selector(switchLayoutsButtonTapped))
        self.navigationItem.rightBarButtonItem = switchLayoutsButton
    }

    /// 設置 UICollectionView
    private func configureCollectionView() {
        drinksCategoryView.collectionView.dataSource = collectionHandler
        drinksCategoryView.collectionView.delegate = collectionHandler
        drinksCategoryView.collectionView.register(ColumnItemCell.self, forCellWithReuseIdentifier: ColumnItemCell.reuseIdentifier)
        drinksCategoryView.collectionView.register(GridItemCell.self, forCellWithReuseIdentifier: GridItemCell.reuseIdentifier)
        
        //  註冊 section header、footer
        drinksCategoryView.collectionView.register(DrinksCategorySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DrinksCategorySectionHeaderView.headerIdentifier)
        drinksCategoryView.collectionView.register(DrinksCategorySectionFooterView.self.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: DrinksCategorySectionFooterView.footerIdentifier)

        collectionHandler.delegate = self
    }
    
    /// 準備兩種佈局：網格視圖與列表視圖，並根據section數量來動態生成佈局
    private func prepareLayouts() {
        let totalSections = collectionHandler.drinks.count
//        print("Total sections: \(totalSections)") // 觀察 section 數量

        // 為每個 section 動態配置佈局
        layouts[.grid] = UICollectionViewCompositionalLayout { sectionIndex, _ in
            self.layoutProvider.getLayout(for: .grid, totalSections: totalSections, sectionIndex: sectionIndex)
        }
        
        layouts[.column] = UICollectionViewCompositionalLayout { sectionIndex, _ in
            self.layoutProvider.getLayout(for: .column, totalSections: totalSections, sectionIndex: sectionIndex)
        }

        // 預設使用 column 佈局
        if let initialLayout = layouts[.column] {
            drinksCategoryView.collectionView.collectionViewLayout = initialLayout
        }
    }


    // MARK: - Data Loading

    /// 從 Firestore 加載特定類別下的飲品數據。
    private func loadDrinkForCategory() {
        guard let categoryId = categoryId else { return }
        
        HUDManager.shared.showLoading(in: view, text: "Loading Drinks...")
        MenuController.shared.loadDrinksForCategory(categoryId: categoryId) { [weak self] result in
            DispatchQueue.main.async {
                HUDManager.shared.dismiss()
                switch result {
                case .success(let subcategoryDrinks):
                    self?.collectionHandler.updateData(drinks: subcategoryDrinks)
                    self?.drinksCategoryView.collectionView.reloadData()
                    self?.prepareLayouts()                                                  // 在數據加載後調用 prepareLayouts，才能獲取正確的 section 數量並生成佈局。
                case .failure(let error):
                    print("Error loading drinks: \(error)")
                    AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self!)
                }
            }
        }
    }
    
    // MARK: - Layout Switching
    
    /// 切換佈局按鈕的點擊事件處理
    @objc private func switchLayoutsButtonTapped() {
        activeLayout = (activeLayout == .grid) ? .column : .grid
    }
    
    /// 應用新的佈局，並在動畫完成後更新按鈕圖示
    private func applyNewLayout() {
        if let newLayout = layouts[activeLayout] {
            self.drinksCategoryView.collectionView.reloadItems(at: self.drinksCategoryView.collectionView.indexPathsForVisibleItems)
            
            drinksCategoryView.collectionView.setCollectionViewLayout(newLayout, animated: true) { (_) in
                switch self.activeLayout {
                case .grid:
                    self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "rectangle.grid.1x2")
                case .column:
                    self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "square.grid.2x2")
                }
            }
        }
    }
  
    // MARK: - Navigation

    // 當執行 segue 時，準備傳遞資料到下一個視圖控制器
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.drinksToDetailSegue,
           let detailVC = segue.destination as? DrinkDetailViewController,
           let selectedDrink = sender as? Drink {
            detailVC.drink = selectedDrink                              // 將選中的飲品傳遞給 DrinkDetailViewController
        }
    }
 
}





// MARK: - reloadData() 版本
/*
 import UIKit

 /// 顯示特定類別下的飲品，並允許用戶在網格和列視圖之間切換。
 class DrinksCategoryViewController: UIViewController {

     // MARK: - Properties

     private let drinksCategoryView = DrinksCategoryView()
     private let collectionHandler = DrinksCategoryHandler()
     private let layoutProvider = DrinksCategoryLayoutProvider()

     // 從上一個視圖控制器傳遞的類別ID、類別標題。
     var categoryId: String?
     var categoryTitle: String?
     
     /// 切換佈局的 Enum
     enum Layout {
         case grid, column
     }
     
     /// 用來儲存目前的布局類型。預設為 .column。
     var activeLayout: Layout = .column {
         didSet {
             applyLayout()
              updateSwitchLayoutsButtonIcon()
         }
     }

     // MARK: - Lifecycle Methods
     override func loadView() {
         view = drinksCategoryView
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupNavigationTitle()
         configureCollectionView()
         loadDrinkForCategory()
         setupSwitchLayoutsButton()
     }
     
     
     // MARK: - Setup Methods

     /// 設置導航標題
     private func setupNavigationTitle() {
         guard let title = categoryTitle else { return }
         self.navigationItem.title = title
     }
     
     /// 設置切換布局按鈕
     private func setupSwitchLayoutsButton() {
         let switchLayoutsButton = UIBarButtonItem(image: UIImage(systemName: "square.grid.2x2"), style: .plain, target: self, action: #selector(switchLayoutsButtonTapped))
         self.navigationItem.rightBarButtonItem = switchLayoutsButton
     }
     
     /// 設置 UICollectionView
     private func configureCollectionView() {
         drinksCategoryView.collectionView.dataSource = collectionHandler
         drinksCategoryView.collectionView.delegate = collectionHandler
         drinksCategoryView.collectionView.register(ColumnItemCell.self, forCellWithReuseIdentifier: ColumnItemCell.reuseIdentifier)
         drinksCategoryView.collectionView.register(GridItemCell.self, forCellWithReuseIdentifier: GridItemCell.reuseIdentifier)
         
         //  註冊 section header 和 footer
         drinksCategoryView.collectionView.register(DrinksCategorySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DrinksCategorySectionHeaderView.headerIdentifier)
         drinksCategoryView.collectionView.register(ThickSeparatorView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ThickSeparatorView.reuseIdentifier)

         collectionHandler.delegate = self
     }
     
     /// 根據當前的佈局應用適當的 UICollectionViewLayout
     private func applyLayout() {
         let layout = layoutProvider.getLayout(for: activeLayout, subcategoryDrinksCount: collectionHandler.drinks.count)
         drinksCategoryView.collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] _ in
             self?.drinksCategoryView.collectionView.reloadData()
         }
     }

     
     // MARK: - Actions
     
     /// 切換佈局按鈕的點擊事件處理
     @objc private func switchLayoutsButtonTapped() {
         activeLayout = (activeLayout == .grid) ? .column : .grid
     }
     
     /// 更新切換佈局按鈕的圖標。
     ///
     /// 如果當前是列佈局，顯示「網格」圖示；如果是網格佈局，顯示「列」圖示
     private func updateSwitchLayoutsButtonIcon() {
         let iconName = activeLayout == .column ? "square.grid.2x2" : "rectangle.grid.1x2"
         self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: iconName)
     }

     // MARK: - Data Loading

     /// 從 Firestore 加載特定類別下的飲品數據。
     private func loadDrinkForCategory() {
         guard let categoryId = categoryId else { return }
         
         HUDManager.shared.showLoading(in: view, text: "Loading Drinks...")
         MenuController.shared.loadDrinksForCategory(categoryId: categoryId) { [weak self] result in
             DispatchQueue.main.async {
                 HUDManager.shared.dismiss()
                 switch result {
                 case .success(let subcategoryDrinks):
                     self?.collectionHandler.updateData(drinks: subcategoryDrinks)
                     self?.applyLayout()  // 確保數據加載完成後應用佈局
                     self?.drinksCategoryView.collectionView.reloadData()
                 case .failure(let error):
                     print("Error loading drinks: \(error)")
                     AlertService.showAlert(withTitle: "Error", message: error.localizedDescription, inViewController: self!)
                 }
             }
         }
     }
   
     // MARK: - Navigation

     // 當執行 segue 時，準備傳遞資料到下一個視圖控制器
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == Constants.Segue.drinksToDetailSegue,
            let detailVC = segue.destination as? DrinkDetailViewController,
            let selectedDrink = sender as? Drink {
             detailVC.drink = selectedDrink // 將選中的飲品傳遞給 DrinkDetailViewController
         }
     }
  
 }
*/
