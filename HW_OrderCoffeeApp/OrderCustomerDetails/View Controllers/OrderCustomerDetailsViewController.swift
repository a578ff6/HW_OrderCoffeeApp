//
//  OrderCustomerDetailsViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/8.
//

// MARK: - ## 關於我的設計需求跟角度，分析來理解和設計 OrderCustomerDetailsViewController 以及 CustomerDetailsManager：

/*
 ## 關於我的設計需求跟角度，分析來理解和設計 OrderCustomerDetailsViewController 以及 CustomerDetailsManager：

 &. 關於 OrderCustomerDetailsViewController 的資料填入設計：
    
    - 主要的問題是在顯示使用者資料（如姓名、電話、地址等）時，是否要事先將這些資料填入對應的輸入欄位，還是給使用者一個選項去決定是否使用 UserDetails 中的資料。

 * 方案 1：自動填入資料
 
    - 在加載 OrderCustomerDetailsViewController 時，如果 UserDetails 中有相關的資料（如姓名、電話、地址），可以直接填入到對應的輸入欄位中，這樣可以簡化使用者的操作。
    - 使用者可以自由地修改這些預填的資料，以適應訂單不一定是本人下的情境。
 
 * 方案 2：提供選項讓使用者選擇
 
    - 可以在每個對應欄位旁設置一個開關（例如勾選框或按鈕），讓使用者選擇是否使用 UserDetails 中的資料。
    - 如果使用者勾選了使用 UserDetails 中的資料，但該資料為空，則提示使用者前往「編輯使用者視圖控制器」補充資料。
 
 ## PS: 根據使用者體驗（UX）來決定。通常，預先填入資料能提升便利性，除非用戶特別偏好選擇自己是否要使用原資料。
 */


// MARK: - 各個元件佈局的設計方向

/*

 * 在建立立了 `CustomerDetailsManager` 來管理顧客資料，後會使 `OrderCustomerDetailsViewController` 變得更簡潔，專注於 UI 和與使用者的交互部分。

 1. OrderCustomerDetailsViewController：
    - 負責顯示和處理與顧客資料的交互，例如讓使用者輸入姓名、電話號碼等資訊。
    - 可以使用 `CustomerDetailsManager` 來初始填入顧客的相關資料。

 2. OrderCustomerDetailsView：
    - 可以設置表單的 UI 元件，比如姓名、電話、取件方式等的輸入框。
    - 將 UI 部分和邏輯部分分開，這樣能夠保持程式碼的清晰度和可維護性。

 3. OrderCustomerDetailsLayoutProvider：
    - 負責提供元件的佈局，包括各個 UI 元件的位置與間距，保持頁面的整齊和一致性。

 4. OrderCustomerDetailsHandler：
    - 可以用來處理用戶操作和事件，比如當用戶選擇宅配時自動顯示地址欄位，或當用戶選擇店取時顯示選店的按鈕。

 5. 元件佈局 Cell：
    - 可以將不同輸入框的邏輯拆分到各自的 Cell 中，這樣可以減少每個 Cell 的複雜度，並且更容易重複使用。
 
 */


// MARK: - 結構處理順序（重要）

/*

 1. 填充初始顧客資料 (`CustomerDetailsManager`)
 
    - 當進入 `OrderCustomerDetailsViewController` 時，首先透過 Firebase 獲取當前的 `UserDetails`，然後使用 `CustomerDetailsManager.populateCustomerDetails(from:)` 方法來填充初始顧客資料。
    - 這樣可以確保在 `UICollectionView` 中的各個 Cell 會顯示用戶之前已經填寫好的資料（如果有的話），例如姓名、電話、取件方式等。

 2. 配置各個 Cell
 
    - 在 `OrderCustomerDetailsHandler` 的 `cellForItemAt` 方法中配置各個 Cell。每個 Cell 的主要目的是收集顧客資料中的不同部分，並將這些資料透過 `CustomerDetailsManager` 進行集中管理。
    - 在每個 Cell 中根據 `CustomerDetailsManager.getCustomerDetails()` 來設置 UI，確保每個 Cell 顯示正確的資料。例如：
      - `OrderCustomerInfoCell`：顯示姓名和電話號碼。
      - `OrderPickupMethodCell`：顯示取件方式和相關的輸入欄位（例如地址或店家名稱）。
      - `OrderCustomerNoteCell`：顯示備註欄位，讓用戶填寫額外的需求。
      - `OrderCustomerSubmitCell`：提供提交訂單的按鈕。

 3. 處理資料變更
    - 在每個 Cell 內部監聽輸入變更，例如使用者編輯電話號碼或更改取件方式時，透過 Callbacks 更新 `CustomerDetailsManager` 的資料。
    - 這樣可以確保每當用戶在 UI 中修改資料時，`CustomerDetailsManager` 都會立即同步更新對應的資料。
    - 例如，在 `OrderPickupMethodCell` 中選擇店家名稱後，更新 `CustomerDetailsManager` 中的 `storeName`。

 4. 驗證顧客資料的完整性
    - 在用戶點擊提交訂單按鈕時，透過 `CustomerDetailsManager.validateCustomerDetails()` 方法來檢查資料是否完整。
    - 若資料不完整，例如缺少姓名或地址，應該顯示提示訊息並阻止提交。（測試用）
    - `OrderCustomerSubmitCell` 可以在按鈕被點擊時執行這個驗證過程。如果驗證通過，則進一步提交訂單到 Firebase。（測試用）
 
    （實作上是當資料不完整時，會禁用按鈕。等到必填資料完成後，才會啟用。）
 
 5. 提交訂單
    - 如果顧客資料通過了驗證，可以開始建立 `Order` 物件。
    - 使用 `CustomerDetailsManager.getCustomerDetails()` 來獲取最新的顧客資料，並與當前的 `orderItems` 組合，創建一個完整的 `Order`。
    - 將這個 `Order` 傳遞給 Firebase，完成訂單的提交。

 
 ### 各個元件的角色和處理流程

 1. `CustomerDetailsManager`
    - 負責存儲和管理顧客資料。
    - 提供填充初始資料、獲取當前資料和驗證資料完整性的功能。
    - 是顧客資料的唯一數據來源，所有的 Cell 都與它交互。

 2. `OrderCustomerDetailsHandler`
    - 作為 `UICollectionViewDataSource`，負責管理各個 Cell。
    - 在每個 Cell 初始化時，從 `CustomerDetailsManager` 獲取資料進行設置。
    - 在各個 Cell 內的回調中，更新 `CustomerDetailsManager` 的資料。

 3. 各個 Cell (`OrderCustomerInfoCell`, `OrderPickupMethodCell`, `OrderCustomerNoteCell`, `OrderCustomerSubmitCell`)
    - 每個 Cell 對應不同的顧客資料輸入部分。
    - 利用回調機制將資料的變更回傳給 `CustomerDetailsManager`，確保每個資料的輸入部分都能及時更新。

 4. `OrderCustomerDetailsViewController`
    - 負責管理頁面的整體邏輯，包括顯示初始資料、處理提交訂單的操作等。
    - 對於提交按鈕的操作，可以利用 `CustomerDetailsManager.validateCustomerDetails()` 來確保所有資料完整。

 5. `OrderManager`
    - 提交整個訂單，因為這涉及將顧客資料 (CustomerDetails) 和訂單項目 (OrderItem) 整合到一個訂單 (Order) 結構中，並完成提交過程。
    - `OrderManager` 可以負責與 Firebase 的交互，例如創建新訂單等。
 
 
 ### 步驟

 1. 填充初始資料：
        - `CustomerDetailsManager` 從 `UserDetails` 中填充資料。
 
 2. 配置 `UICollectionView` 的 Cell：
        - 通過 `OrderCustomerDetailsHandler` 根據 `CustomerDetailsManager` 填充資料。
 
 3. 監聽資料變更：
        - 各個 Cell 使用回調方式更新 `CustomerDetailsManager`。
 
 4. 提交訂單：
        - `OrderCustomerSubmitCell` 點擊後驗證資料完整性，成功後將訂單提交至 Firebase。

*/


// MARK: - OrderCustomerDetailsViewController 重點筆記：

/*
 
 ## OrderCustomerDetailsViewController 重點筆記：

    * 視圖控制器的作用：
 
        - OrderCustomerDetailsViewController 是用於顯示和處理顧客詳細資料的核心視圖控制器，這些資料是訂單提交所必須的。
        - 提供用戶填寫姓名、電話、取件方式和備註，並確保這些資料正確且完整後才能提交訂單。
 
    * 主要的設置方法：

        - setupViewController()：初始化視圖控制器，包括導航欄標題設置和資料處理器初始化。
        - fetchAndPopulateUserDetails()：從 Firebase 獲取用戶的詳細資料，並填充到顧客資料中，最後刷新表單來顯示這些資料。
 
    * 表單驗證與按鈕狀態：
 
        - updateSubmitButtonState()：每當顧客資料變更時，檢查資料是否完整並根據結果啟用或禁用提交按鈕，避免不完整的訂單提交。
 
    * 代理方法的用途：

        - customerDetailsDidChange()：當顧客資料有變更時被調用，從而觸發 updateSubmitButtonState() 確保即時更新。
        - submitOrder()：當用戶點擊提交按鈕時執行，通過 OrderManager 進行訂單提交。
 */

// MARK: - 「submit」按鈕的邏輯判斷，與 CustomerDetailsManager 設計方向。（重要）

/*
 
 - 當初在建構 CustomerDetailsManager 的時候，是想說透過點擊 submit 按鈕後來透過「警告訊息」得知「資料」是否有填寫完成。並且也是方便去做 Test。
 - 因此原邏輯適合在「按鈕沒有啟用禁用的邏輯，並顯示警告訊息」的情況下，因為初始狀態下按鈕始終處於可點擊狀態，直到提交訂單時才會根據驗證結果顯示警告。
 - 然而，我後來決定將 OrderCustomerDetailsViewController 與 OrderViewController 的按鈕風格進行統一，希望按鈕能根據欄位的「填寫狀態」啟用或禁用時，要在畫面初始載入時應進行檢查。
 
 &. 選擇設計：

    * 按鈕沒有啟用禁用的邏輯，並顯示警告訊息（方案1）：

        - 如果希望用戶可以隨時嘗試提交訂單，即便某些必填欄位未填寫，這樣的設計會更合適。
        - 當用戶點擊提交按鈕時，可以顯示一個警告或提示，用戶需完成某些欄位才能繼續。這樣能夠讓用戶有更多的控制權，也更能吸引注意力到需要修正的部分。
        - 此方式較適合那些希望給用戶更多靈活性、避免用戶在填寫時感到受限的應用場景。
 
    * 按鈕會有啟用禁用的邏輯（方案2）：

        - 如果想要強制用戶在所有必填欄位都完成後才能提交訂單，這種方式會更合適。
        - 禁用提交按鈕直到所有必填欄位都正確填寫，可以減少用戶的錯誤操作，從而提升用戶體驗和資料正確性。
        - 這種方式特別適合那些必須保證每個提交操作都正確無誤的應用場景，例如在外送或支付相關流程中，這樣做可以降低出現錯誤的機會。
 
    * 依照構想情境：
        - 如果用戶在沒有填寫必填欄位的情況下仍可點擊按鈕並提交訂單，且會顯示錯誤訊息，那麼方案1適合原本的邏輯。
        - 然而，如果我改成想更積極地防止用戶提交錯誤資料，方案2會更好，特別是當這些資料對於訂單的完整性非常重要時。

 &. 建議：

        - 如果要保持方案1的邏輯，可以加入詳細的錯誤提示，讓用戶知道哪些欄位需要完成。
        - 如果想改成方案2，需要注意按鈕的初始狀態及欄位狀態變更時即時更新，避免一開始按鈕就被誤啟用。
 */


// MARK: - 關於 OrderCustomerDetailsViewController 的 updateSubmitButtonState() 和 cellForItemAt 中的按鈕狀態設置

/*
 
 ## 關於 OrderCustomerDetailsViewController 的 updateSubmitButtonState() 和 cellForItemAt 中的按鈕狀態設置：
 
 - OrderCustomerDetailsViewController 的 updateSubmitButtonState() 和 OrderCustomerDetailsHandler 中 cellForItemAt 的按鈕狀態設置有相似的邏輯，但它們在不同的時機被調用，因此它們在功能上還是有所區分的：

 
    1. cellForItemAt 中的按鈕狀態設置：
    
        - 這部分負責在每次創建 SubmitCell 時進行按鈕狀態的初始設置。也就是當 SubmitCell 在畫面中被展示時，能根據當前的資料狀態初始化按鈕的可用性。
        - 在第一次進入畫面、reloadData() 之後或當 Collection View 滑動而需要重新加載 Cell 時會被調用。
 
    2. OrderCustomerDetailsViewController 的 updateSubmitButtonState()：

        - 這個方法在資料變更時被調用，例如顧客在輸入姓名、電話或選擇取件方式時，以確保資料變更後按鈕狀態即時更新。
        - 它適用於動態資料更新的情境，尤其是當用戶對資料進行修改時，即時判斷表單是否已填滿。

    3. 因此，這兩部分可以保持分開使用：

        - cellForItemAt 負責初始化狀態，確保在 Cell 創建時狀態正確。
        - updateSubmitButtonState() 負責在資料變更時動態更新，保持按鈕狀態即時響應。

 */

import UIKit

/// OrderCustomerDetailsViewController 是一個用於顯示和處理顧客詳細資料的視圖控制器
///
/// 主要功能包括填寫顧客的姓名、電話、取件方式、備註等資料，以便提交訂單。它包括自定義的 OrderCustomerDetailsView，以及使用 OrderCustomerDetailsHandler 來處理表單填寫的交互。
class OrderCustomerDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 用於存放訂單資料
    var orderItems: [OrderItem] = []
    
    /// 自訂的 OrderCustomerDetailsView，用於`展示訂單訂單填寫資訊項目`
    private let orderCustomerDetailsView = OrderCustomerDetailsView()
    
    /// 處理`訂單顧客資料`的 OrderCustomerDetailsHandler
    private var ordercustomerDetailsHandler: OrderCustomerDetailsHandler!
    
    // MARK: - Lifecycle Methods
    
    /// 設置 OrderCustomerDetailsView 作為主視圖
    override func loadView() {
        view = orderCustomerDetailsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        fetchAndPopulateUserDetails()
        logOrderItemsCount()
    }
    
    // MARK: - Setup Methods
    
    /// 配置 ViewController 相關設定
    private func setupViewController() {
        setupNavigationTitle()
        setupOrderDetailsHandler()
        setupDelegate()
    }
    
    /// 設置導航欄的標題
    private func setupNavigationTitle() {
        title = "Customer Details"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    /// 設置 OrderCustomerDetailsHandler
    private func setupOrderDetailsHandler() {
        ordercustomerDetailsHandler = OrderCustomerDetailsHandler(collectionView: orderCustomerDetailsView.collectionView)
    }
    
    /// 設置委託
    private func setupDelegate() {
        ordercustomerDetailsHandler.delegate = self
    }
    
    // MARK: - Data Handling
    
    /// 從 Firebase 獲取`當前用戶資料`並填充 CustomerDetails
    private func fetchAndPopulateUserDetails() {
        Task {
            do {
                let userDetails = try await FirebaseController.shared.getCurrentUserDetails()
                CustomerDetailsManager.shared.populateCustomerDetails(from: userDetails)
                // 刷新 collection view 以顯示已填寫的資料
                orderCustomerDetailsView.collectionView.reloadData()
            } catch {
                print("獲取用戶資料時發生錯誤：\(error)")
            }
        }
    }
    
    /// `測試用`：觀察訂單項目數量，確認傳遞的資料是否正確
    private func logOrderItemsCount() {
        print("接收到的訂單項目數量：\(orderItems.count)")
    }
    
    // MARK: - 更新提交按鈕狀態
    
    /// 在每次顧客資料變更（例如姓名、電話、地址等變更）時，調用 updateSubmitButtonState() 方法來檢查資料是否完整
    ///
    /// 根據顧客資料的驗證結果來啟用或禁用提交按鈕。這樣可以確保用戶在所有必要資料未完整前無法提交訂單。
    func updateSubmitButtonState() {
        let validationResult = CustomerDetailsManager.shared.validateCustomerDetails()
        let isFormValid = (validationResult == .success)
        print("更新提交按鈕狀態: \(isFormValid ? "啟用" : "禁用") - 由於：\(validationResult)")
        
        // 獲取提交按鈕所在的 indexPath，並更新按鈕狀態
        let submitIndexPath = IndexPath(item: 0, section: OrderCustomerDetailsHandler.Section.submitAction.rawValue)
        
        if let submitCell = orderCustomerDetailsView.collectionView.cellForItem(at: submitIndexPath) as? OrderCustomerSubmitCell {
            submitCell.configureSubmitButton(isEnabled: isFormValid)
        }
    }
}

// MARK: - OrderCustomerDetailsHandlerDelegate
extension OrderCustomerDetailsViewController: OrderCustomerDetailsHandlerDelegate {

    /// 當顧客資料有變更時調用
    ///
    /// 通過更新提交按鈕狀態來即時反映顧客資料的變更，以確保表單驗證邏輯始終準確。
    func customerDetailsDidChange() {
        updateSubmitButtonState()
    }
    
    /// 用於處理提交訂單的操作
    ///
    /// 當用戶點擊提交按鈕時調用，這裡會調用 OrderManager 來`提交訂單`並在成功或失敗後給予回應。
    func submitOrder() {
        AlertService.showAlert(withTitle: "確認提交訂單", message: "您確定要提交訂單嗎？", inViewController: self, showCancelButton: true) { [weak self] in
            guard let self = self else { return }
            
            Task {
                do {
                    try await OrderManager.shared.submitOrder()
                    print("訂單已成功提交")
                    // 提交成功後的操作，例如返回上個畫面或更新 UI
                } catch {
                    print("訂單提交失敗：\(error.localizedDescription)")
                    // 顯示錯誤提示(或者改成跳出一個失敗的畫面)
                    AlertService.showAlert(withTitle: "提交失敗", message: "訂單提交過程中出現錯誤，請稍後再試。", inViewController: self, showCancelButton: false, completion: nil)
                }
            }
        }
    }
}



// MARK: - 初步構想 Methods（進入到）

/*
 /// 打開店家選擇視圖（可能會使用到委託）
 func openStoreSelectionView() {
     // 例如：使用導航控制器推入一個選擇店家的頁面
     let storeSelectionViewController = StoreSelectionViewController()
     storeSelectionViewController.onStoreSelected = { [weak self] storeName in
         self?.updateSelectedStore(storeName)
     }
     navigationController?.pushViewController(storeSelectionViewController, animated: true)
 }

 /// 更新選擇的店家名稱
  func updateSelectedStore(_ storeName: String) {
      CustomerDetailsManager.shared.updateStoreName(storeName)
      orderCustomerDetailsView.collectionView.reloadData()
  }

  /// 驗證地址
  func validateAddress(_ address: String) {
      // 在這裡實現地址驗證的邏輯
  }
 */
