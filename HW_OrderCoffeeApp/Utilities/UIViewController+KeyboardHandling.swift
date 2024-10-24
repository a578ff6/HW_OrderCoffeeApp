//
//  UIViewController+KeyboardHandling.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/8/28.
//

/// NOTE: 由於已使用 IQKeyboardManager 進行鍵盤管理，這部分功能已被取代，無需再手動設置。
/*
import UIKit

// 擴展 UIViewController，添加處理鍵盤顯示和隱藏的功能，避免鍵盤遮擋輸入框
extension UIViewController {

    /// 設置鍵盤顯示和隱藏的觀察者
    /// - Parameter scrollView: 傳入需要調整的 UIScrollView 或 UITableView
    func setupKeyboardObservers(for scrollView: UIScrollView) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 鍵盤顯示時的處理
    /// - Parameter notification: 包含鍵盤資訊的通知物件
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    /// 鍵盤隱藏時的處理
    /// - Parameter notification: 包含鍵盤資訊的通知物件
    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
}
*/

