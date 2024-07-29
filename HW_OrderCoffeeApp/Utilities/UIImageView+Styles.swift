//
//  UIImageView+Styles.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/20.
//


import UIKit

extension UIImageView {
    
    func makeRounded() {
        self.layer.borderWidth = 2
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }

}

