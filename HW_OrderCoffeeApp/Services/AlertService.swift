//
//  AlertService.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/15.
//

// MARK: - 問題：UIAlertController 按鈕顏色變成不一致

/*
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

import UIKit

/// 警告視窗
class AlertService {
    
    /// 用於創建並顯示一個標準的警告彈窗，並在點擊後執行 completion
    /// - Parameters:
    ///   - title: 警告彈窗的標題
    ///   - message: 警告彈窗的訊息
    ///   - inViewController: 彈窗所顯示的視圖控制器
    ///   - showCancelButton: 是否顯示取消按鈕，默認為 false
    ///   - completion: 用戶點擊確定後執行的操作
    /// - Note: 顯式設置按鈕的文字顏色以確保在某些視圖或主題設定影響下仍保持一致顯示。
    static func showAlert(withTitle title: String, message: String, inViewController viewController: UIViewController, showCancelButton: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = createAlertAction(title: "確定", style: .default, color: UIColor.deepGreen) {
            completion?()
        }
        alert.addAction(confirmAction)
        
        if showCancelButton {
            let cancelAction = createAlertAction(title: "取消", style: .cancel, color: UIColor.deepGreen)
            alert.addAction(cancelAction)
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// 用於創建並顯示一個標準的 ActionSheet，並在點擊後執行 completion
    static func showActionSheet(withTitle title: String, message: String, inViewController viewController: UIViewController, showCancelButton: Bool = true, completion: (() -> Void)? = nil) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let confirmAction = createAlertAction(title: "確定", style: .default, color: UIColor.deepGreen) {
            completion?()
        }
        actionSheet.addAction(confirmAction)
        
        if showCancelButton {
            let cancelAction = createAlertAction(title: "取消", style: .cancel, color: UIColor.deepGreen)
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
    
    /// 按鈕創建
    private static func createAlertAction(title: String, style: UIAlertAction.Style, color: UIColor, handler: (() -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style) { _ in
            handler?()
        }
        action.setValue(color, forKey: "titleTextColor")
        return action
    }

}
