//
//  UIViewController+HideKeyboard.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

import UIKit


/// UIViewController 的擴展，添加點擊背景收起鍵盤的功能
extension UIViewController {
    
    /// 設置點擊背景收起鍵盤
    func setUpHideKeyboardOntap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // 隱藏鍵盤的方法
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

