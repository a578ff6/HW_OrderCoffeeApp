//
//  CategoryCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

import UIKit
import Kingfisher

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCornerRadius()
        categoryImageView.makeRounded()
    }

    
    private func setupCornerRadius() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 2.0
        contentView.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
    }
    
    
    func update(with category: Category) {
        categoryImageView.kf.setImage(with: category.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        titleLabel.text = category.title
    }
    
}

