//
//  AlertService.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/15.
//

// MARK: - 問題：UIAlertController 按鈕顏色變成不一致
/**
 ## 問題：UIAlertController 按鈕顏色變成不一致

    - 在使用 UIAlertController 顯示警告彈窗時，按鈕的文字顏色預設應該為藍色，但在某些情況下按鈕顏色會變成黑色。
    - 例如，當按鈕被點擊後，按鈕的顏色從藍色變成黑色，而非保持原本的藍色。

 * 原因：

    - UIAlertController 中的按鈕顏色受 UIView 的 tintColor 影響。
    - 如果警告框所在的視圖或父視圖的 tintColor 被更改，這可能導致按鈕顏色變得不一致，從而出現按鈕顏色變成黑色的情況。

 * 解決方法：

    - 使用 setValue(_:forKey:) 方法顯式設定按鈕的文字顏色。
    - 使用 setValue(_:forKey:) 方法設置按鈕的 titleTextColor，可以確保按鈕的文字顏色無論在按下前或按下後，都保持預期的顏色。
    - 這樣的顯式設置可以避免因為視圖或系統主題的變化而導致顏色顯示異常。
 */


// MARK: - AlertService 類別的使用情境和設計考量
/**
 ## AlertService 類別的使用情境和設計考量
 
 `1. 使用 AlertService`
 
 - 在多個視圖控制器中，有時需要重複創建和顯示類似的警告視窗或操作表，這樣的重複程式碼會讓程式變得冗長和難以維護。
 - AlertService 將顯示警告的邏輯封裝起來，通過提供簡單的靜態方法來統一顯示警告視窗，更簡潔、可重複使用，並保持一致的風格。
 
 `2. 按鈕文字顏色顯式設置的原因`
 
 - 在不同的主題模式（例如深色模式）或不同視圖的背景設定下，按鈕的顏色可能會隨著系統的外觀而改變。
 - 通過 `action.setValue(color, forKey: "titleTextColor") `顯式設置按鈕顏色，可以確保按鈕在所有情況下都具有一致的顯示效果，避免顏色與背景混淆導致難以辨識。
 
 `3. showActionSheet 和 showAlert 方法`
 
 - UIAlertController 提供了兩種不同的樣式：alert 和 actionSheet，前者更適合顯示重要信息讓用戶做決策，而後者更適合顯示選項列表。
 - 通過分別實現這兩個方法，能夠根據使用場景靈活選擇適當的彈窗形式，從而提升用戶體驗。
 
 `4. 在 iPad 上顯示 ActionSheet 的特殊處理`
 
 - 在 iPad 上顯示 UIActionSheet 時，如果沒有設置 popoverPresentationController，會導致應用崩潰。
 - 因此，在 showActionSheet 方法中，檢查 popoverPresentationController，並對其進行配置以確保操作表能夠正常顯示。
 */

import UIKit

/// `AlertService` 顯示不同類型的警告視窗 (UIAlertController) 和操作表 (UIActionSheet)。
/// 通過封裝的靜態方法，簡化了在多個視圖控制器中重複創建和顯示警告視窗的工作。
class AlertService {
    
    /// 用於創建並顯示一個標準的警告彈窗，並在點擊後執行 completion
    /// - Parameters:
    ///   - title: 警告彈窗的標題
    ///   - message: 警告彈窗的訊息
    ///   - inViewController: 彈窗所顯示的視圖控制器
    ///   - confirmButtonTitle: 確認按鈕的文字，默認為 "確定"
    ///   - cancelButtonTitle: 取消按鈕的文字，默認為 "取消"
    ///   - showCancelButton: 是否顯示取消按鈕，默認為 false
    ///   - completion: 用戶點擊確定後執行的操作
    /// - Note: 顯式設置按鈕的文字顏色以確保在某些視圖或主題設定影響下仍保持一致顯示。
    static func showAlert(withTitle title: String, message: String, inViewController viewController: UIViewController, confirmButtonTitle: String = "確定", cancelButtonTitle: String = "取消", showCancelButton: Bool = false, completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAction = createAlertAction(title: confirmButtonTitle, style: .default, color: UIColor.deepGreen) {
            completion?()
        }
        alert.addAction(confirmAction)
        
        if showCancelButton {
            let cancelAction = createAlertAction(title: cancelButtonTitle, style: .cancel, color: UIColor.deepGreen)
            alert.addAction(cancelAction)
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// 用於創建並顯示一個標準的 ActionSheet，並在點擊後執行 completion
    /// - Parameters:
    ///   - title: 警告彈窗的標題
    ///   - message: 警告彈窗的訊息
    ///   - inViewController: 彈窗所顯示的視圖控制器
    ///   - confirmButtonTitle: 確認按鈕的文字，默認為 "確定"
    ///   - cancelButtonTitle: 取消按鈕的文字，默認為 "取消"
    ///   - showCancelButton: 是否顯示取消按鈕，默認為 false
    ///   - completion: 用戶點擊確定後執行的操作
    /// - Note: 當在 iPad 上顯示時，需設置 `popoverPresentationController` 來確保操作表能正確顯示。
    static func showActionSheet(withTitle title: String, message: String, inViewController viewController: UIViewController, confirmButtonTitle: String = "確定", cancelButtonTitle: String = "取消", showCancelButton: Bool = true, completion: (() -> Void)? = nil) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let confirmAction = createAlertAction(title: confirmButtonTitle, style: .default, color: UIColor.deepGreen) {
            completion?()
        }
        actionSheet.addAction(confirmAction)
        
        if showCancelButton {
            let cancelAction = createAlertAction(title: cancelButtonTitle, style: .cancel, color: UIColor.deepGreen)
            actionSheet.addAction(cancelAction)
        }
        
        // 如果是在 iPad 上需要指定 popover 的 sourceView
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = viewController.view
            popoverPresentationController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    /// 用於創建一個具有自定義顏色的 UIAlertAction 按鈕
    /// - Parameters:
    ///   - title: 按鈕的標題
    ///   - style: 按鈕的樣式
    ///   - color: 按鈕的文字顏色
    ///   - handler: 點擊按鈕後執行的操作
    /// - Returns: 配置好的 UIAlertAction 物件
    private static func createAlertAction(title: String, style: UIAlertAction.Style, color: UIColor, handler: (() -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style) { _ in
            handler?()
        }
        action.setValue(color, forKey: "titleTextColor")
        return action
    }

}
