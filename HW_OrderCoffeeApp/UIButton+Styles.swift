//
//  UIButton+Styles.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/14.
//

import UIKit

extension UIButton {
    
    func styleFilledButton() {
        self.backgroundColor = UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1)
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        self.layer.cornerRadius = self.frame.height / 4
        self.clipsToBounds = true
        self.tintColor = UIColor.white
    }
    
    
    func styleHollowButton() {
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1).cgColor
        self.layer.cornerRadius = self.frame.height / 4
        self.clipsToBounds = true
        self.tintColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1)
    }
    
        
}
