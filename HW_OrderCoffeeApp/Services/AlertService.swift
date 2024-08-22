//
//  AlertService.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/15.
//

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
    static func showAlert(withTitle title: String, message: String, inViewController viewController: UIViewController, showCancelButton: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            completion?()
        }))
        if showCancelButton {
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        }
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
