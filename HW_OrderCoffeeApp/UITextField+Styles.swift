//
//  UITextField+Styles.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

import UIKit


extension UITextField {
    
    func styleTextField() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.init(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        
        self.borderStyle = .none
        self.layer.addSublayer(bottomLine)
    }
    
}

