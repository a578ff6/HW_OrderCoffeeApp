//
//  StoreInfoViewController.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/29.
//

// MARK: - StoreInfoViewController 重點筆記
/*
 ## StoreInfoViewController 重點筆記

 1. 控制器分離與視圖組合
    - StoreInfoViewController 中使用了 StoreInfoView 作為控制器的根視圖，使視圖層邏輯更加清晰，便於重用和維護。

 2. 根視圖使用 loadView 設置
    - 通過 loadView() 方法來指定控制器的根視圖為 StoreInfoView，這樣視圖的佈局可以完全由 StoreInfoView 自行管理，而 StoreInfoViewController 只需專注於控制器的邏輯部分。

 3. 雙視圖切換的邏輯
    - StoreInfoView 包含 DefaultInfoView 和 SelectStoreInfoView 兩個子視圖，分別用來顯示「初始提示資訊」和「選擇的門市資訊」。
    - 通過隱藏與顯示這兩個子視圖來實現界面的狀態切換，使邏輯簡單明確。

 4. 視圖的設置與資料配置分離
    - setupViews() 方法負責定義視圖的佈局，而 configure(with:) 方法負責將資料填充到 UI 元素中，確保佈局與數據配置的分離。

 5. 按鈕行為建議
    - 「撥打電話」按鈕的回調行為使用 Action Sheet，提供更好的用戶體驗，讓用戶在執行撥打電話前能夠確認。
    - 「選擇門市」按鈕可根據具體邏輯，使用 Alert 或 Action Sheet 來提示用戶後續動作的確認，具體取決於交互需求。
 */


import UIKit
import CoreLocation

/// 用於顯示「提示選擇門市資訊」與「門市詳細資訊」的視圖控制器
///
/// - `StoreInfoViewController`的作用是用來顯示當前選擇的店家詳細資訊，或者當沒有選擇店家時，顯示預設的提示資訊。
class StoreInfoViewController: UIViewController {
    
    // MARK: - Properties
    
    /// StoreInfoView 是自定義的 UIView，包含「預設提示資訊視圖」與「選擇的門市資訊視圖」
    private let storeInfoView = StoreInfoView()
    
    // MARK: - Lifecycle Methods
    
    override func loadView() {
        self.view = storeInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    // MARK: - Configure
    
    /// 設定 StoreInfoViewController 的初始狀態（顯示提示訊息）
    /// - Parameter message: 提示訊息文字
    func configureInitialState(with message: String) {
        storeInfoView.defaultInfoView.configure(with: message)
        storeInfoView.defaultInfoView.isHidden = false
        storeInfoView.selectStoreInfoView.isHidden = true
    }
    
    /// 設定 StoreInfoViewController 來顯示門市詳細資訊
    /// - Parameters:
    ///   - store: 門市資料
    ///   - distance: 與用戶之間的距離
    ///   - todayHours: 今日營業時間
    func configure(with store: Store, distance: CLLocationDistance?, todayHours: String?) {
        let formattedPhoneNumber = StoreManager.shared.formatPhoneNumber(store.phoneNumber)
        storeInfoView.selectStoreInfoView.configure(with: store, formattedPhoneNumber: formattedPhoneNumber, distance: distance, todayHours: todayHours)
        storeInfoView.defaultInfoView.isHidden = true
        storeInfoView.selectStoreInfoView.isHidden = false
        
        // 設置按鈕回調行為
        setupCallPhoneAction(for: store)
        setupSelectStoreAction(for: store)
    }
    
    // MARK: - Setup Button Actions
    
    /// 設置撥打電話按鈕的回調行為
    /// - Parameter store: 店鋪資料
    private func setupCallPhoneAction(for store: Store) {
        storeInfoView.selectStoreInfoView.onCallPhoneTapped = {
            AlertService.showActionSheet(withTitle: "撥打電話", message: "確定要撥打電話給「\(store.name)」嗎？", inViewController: self, showCancelButton: true) {
                guard let phoneURL = URL(string: "tel://\(store.phoneNumber)") else {
                    print("Invalid phone number")
                    return
                }
                
                if UIApplication.shared.canOpenURL(phoneURL) {
                    UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
                } else {
                    print("Can't make phone call")
                }
            }
        }
    }
    
    /// 設置選擇門市按鈕的回調行為
    /// - Parameter store: 店鋪資料
    private func setupSelectStoreAction(for store: Store) {
        storeInfoView.selectStoreInfoView.onSelectStoreTapped = {
            AlertService.showAlert(withTitle: "選擇門市", message: "你確定要選擇「\(store.name)」作為取件門市嗎？", inViewController: self, showCancelButton: true) {
                // 根據App邏輯處理選擇店鋪的動作
                // self.setSelectedStore(store)
            }
        }
    }
    
}
