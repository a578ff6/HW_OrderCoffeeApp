//
//  BottomLineTextField.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/19.
//

/*
 1. BottomLineTextField 在 layoutSubviews 中更新「底線」的 frame，確保「底線」在 UITextField 的 frame 確定之後設置正確。
    * 藉此不依賴於外部調用和佈局的時機。
    * 同時避免重複建立底線層的問題。
 */

import UIKit

/// 自訂一個底線的 TextField
class BottomLineTextField: UITextField {

    private let bottomLine = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBottomLine()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBottomLine()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBottomLineFrame()
    }

    private func setupBottomLine() {
        bottomLine.backgroundColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        layer.addSublayer(bottomLine)
    }

    private func updateBottomLineFrame() {
        bottomLine.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 2)
    }

}
