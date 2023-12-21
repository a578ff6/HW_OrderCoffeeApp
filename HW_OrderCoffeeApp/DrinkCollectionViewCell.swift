//
//  DrinkCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/19.
//

import UIKit
import Kingfisher

class DrinkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkSubNameLabel: UILabel!
    
    func configure(with drink: Drink) {
        drinkImageView.kf.setImage(with: drink.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        drinkNameLabel.text = drink.name
        drinkSubNameLabel.text = drink.subName
    }
    
}


