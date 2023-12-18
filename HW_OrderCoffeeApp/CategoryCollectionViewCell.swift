//
//  CategoryCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCornerRadius()
    }

    
    private func setupCornerRadius() {
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
    }
    
    
    func update(with category: Category) {
        categoryImageView.kf.setImage(with: category.imageUrl, placeholder: UIImage(systemName: "photo.fill"))
        titleLabel.text = category.title
    }
    
}

