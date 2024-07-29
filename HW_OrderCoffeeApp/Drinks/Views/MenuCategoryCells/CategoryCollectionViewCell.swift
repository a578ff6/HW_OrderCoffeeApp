//
//  CategoryCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/18.
//

import UIKit
import Kingfisher

/// 飲品種類的Cell，用於 MenuCollectionViewController
class CategoryCollectionViewCell: UICollectionViewCell {
    
    let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellAppearance() {
        self.layer.cornerRadius = 25
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        
        // 設置 contentView 背景顏色
        self.contentView.backgroundColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 0.75)
    }
    
    private func setupViews() {
        contentView.addSubview(categoryImageView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            categoryImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            categoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            categoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            // categoryImageView.heightAnchor.constraint(equalTo: categoryImageView.widthAnchor),
            
            // 修改高度约束，允許高度調整
            categoryImageView.heightAnchor.constraint(lessThanOrEqualTo: categoryImageView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: categoryImageView.bottomAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        ])
    }
    
    /// 使用類別數據更新單元格。
    func update(with category: Category) {
        categoryImageView.kf.setImage(with: category.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        titleLabel.text = category.title
        subtitleLabel.text = category.subtitle
    }
}
