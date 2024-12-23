//
//  DrinkDetailShareManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/12/19.
//

// MARK: - DrinkDetailShareManager 筆記
/**
 
 ## DrinkDetailShareManager 筆記
 
 `* What`
 
 - `DrinkDetailShareManager` 是一個專門負責處理飲品詳細資訊分享邏輯的類別，包含以下功能：
 
   1. 根據飲品資料模型動態生成分享文字內容。
   2. 加載飲品圖片，並與文字內容一起分享。
   3. 使用 `UIActivityViewController` 提供原生分享介面，讓用戶可選擇分享目標。
 
 ---------------------
 
 `* Why`
 
 `1.清晰的職責分工：`
 
 - 將分享邏輯集中於此類別，遵循單一職責原則（SRP），讓控制器專注於頁面整合與數據管理。
 
 `2.增強可重用性：`
 
 - 分享邏輯可被其他場景重用，例如不同商品類型或類似的分享功能，提升代碼靈活性。
 
 `3.提升用戶體驗：`
 
 - 當圖片加載失敗時，仍然可以提供純文字分享，確保功能完整性。
 
 ---------------------
 
 `* How`
 
 `1.方法分工：`
 
 - 文字生成： 使用 `generateShareText` 方法，將與飲品相關的文字描述獨立處理。
 - 圖片加載： 使用 `loadImage` 方法，透過 `Kingfisher` 工具負責圖片加載並處理失敗情況。
 - 分享界面： 使用 `presentShareController` 方法，展示分享介面，保持與視圖層交互清晰簡單。
 
 `2.分享流程：`
 
 - 控制器傳遞 `drinkDetailModel` 和 `selectedSize` 給 `DrinkDetailShareManager`。
 - 動態生成分享文字並嘗試加載圖片。
 - 完成後，使用 `UIActivityViewController` 顯示分享內容。
 
 ---------------------
 
 `* 注意事項`
 
 `1.數據依賴性：`
 
 - 本類別不持有 `drinkDetailModel` 或 `selectedSize`，數據由控制器提供，確保數據集中管理。
 
 `2.圖片加載的異步處理：`
 
 - 圖片加載可能需要一定時間，確保處理結果後正確更新分享內容。
 
 `3.錯誤處理：`
 
 - 圖片加載失敗時，應避免影響整體分享流程，改用純文字進行分享。
  */


// MARK: - (v)

import UIKit
import Kingfisher


/// 負責處理飲品詳細資訊分享的邏輯
///
/// `DrinkDetailShareManager` 的設計遵循單一職責原則，專注於飲品的分享功能，包含文字生成、圖片加載及顯示分享介面。
///
/// ### 功能說明
/// - 根據 `drinkDetailModel` 和 `selectedSize` 動態生成分享內容。
/// - 嘗試下載飲品圖片，並在成功時附加至分享內容中。
/// - 提供原生分享介面，讓用戶可選擇分享目標。
class DrinkDetailShareManager {
    
    // MARK: - Public Methods
    
    /// 分享飲品資訊
    ///
    /// 包括飲品的文字描述與圖片（若加載成功），以 `UIActivityViewController` 的形式展示分享介面。
    /// - Parameters:
    ///   - drinkDetailModel: 當前飲品的詳細資料模型
    ///   - selectedSize: 使用者選中的飲品尺寸
    ///   - viewController: 用於展示分享介面的視圖控制器
    func share(drinkDetailModel: DrinkDetailModel, selectedSize: String, from viewController: UIViewController) {
        let shareText = generateShareText(drinkDetailModel: drinkDetailModel, selectedSize: selectedSize)
        loadImage(imageUrl: drinkDetailModel.imageUrl) { image in
            let shareItems: [Any] = image != nil ? [shareText, image!] : [shareText]
            self.presentShareController(with: shareItems, from: viewController)
        }
    }
    
    // MARK: - Private Methods
    
    /// 生成分享文字內容
    ///
    /// 包含飲品名稱、描述，以及選中尺寸的價格與熱量資訊。
    /// - Parameters:
    ///   - drinkDetailModel: 當前飲品的詳細資料模型
    ///   - selectedSize: 使用者選中的飲品尺寸
    /// - Returns: 分享用的文字描述
    private func generateShareText(drinkDetailModel: DrinkDetailModel, selectedSize: String) -> String {
        var shareText = """
            推薦您這款飲品：
            \(drinkDetailModel.name)
            \(drinkDetailModel.description)
         """
        
        if let sizeInfo = drinkDetailModel.sizeDetails[selectedSize] {
            shareText += """
               
            尺寸：\(selectedSize)
            價格：\(sizeInfo.price)元
            熱量：\(sizeInfo.calories)大卡
            """
        }
        return shareText
    }
    
    /// 加載飲品圖片
    ///
    /// 使用 `Kingfisher` 圖片加載工具下載飲品圖片。若加載成功，回傳圖片；失敗則回傳 nil。
    /// - Parameters:
    ///   - imageUrl: 飲品圖片的 URL
    ///   - completion: 加載完成後的回調，返回 `UIImage` 或 `nil`
    private func loadImage(imageUrl: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                print("圖片加載失敗：\(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    /// 顯示分享視圖
    ///
    /// 創建並展示 `UIActivityViewController` 以供分享。
    /// - Parameters:
    ///   - shareItems: 要分享的內容，包含文字與圖片
    ///   - from: 用於展示分享介面的視圖控制器
    private func presentShareController(with items: [Any], from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
    
}
