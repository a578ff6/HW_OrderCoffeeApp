//
//  FavoriteDrinkCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/19.
//

import UIKit

/// 配置`我的最愛`的圖片、名稱、副名稱
class FavoriteDrinkCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FavoriteDrinkCell"
    
    // MARK: - UI Elements
    
    let drinkImageView = createImageView(contentMode: .scaleAspectFill, cornerRadius: 15)
    let nameLabel = createLabel(fontSize: 16, numberOfLines: 1, textColor: .deepBrown, isBold: true)
    let subNameLabel = createLabel(fontSize: 14, numberOfLines: 0, textColor: .gray, isBold: false)
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置 Cell 外觀
    private func setupCellAppearance() {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.contentView.backgroundColor = .lightWhiteGray
    }

    /// 配置 Cell 的視圖佈局
    private func setupViews() {
        let stackView = FavoriteDrinkCell.createStackView(arrangedSubviews: [nameLabel, subNameLabel], axis: .vertical, spacing: 4)
        
        contentView.addSubview(drinkImageView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // 垂直置中圖片
            drinkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            drinkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            drinkImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 70),
            drinkImageView.heightAnchor.constraint(equalTo: drinkImageView.widthAnchor),

            // 讓 stackView 中心與圖片的中心對齊
            stackView.centerYAnchor.constraint(equalTo: drinkImageView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: drinkImageView.trailingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Factory Methods

    private static func createImageView(contentMode: UIView.ContentMode, cornerRadius: CGFloat) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = contentMode
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }
    
    private static func createLabel(fontSize: CGFloat,numberOfLines: Int, textColor: UIColor, isBold: Bool) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }
    
    private static func createStackView(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
    
    // MARK: - Configure Method

    /// 設置 飲品圖片、名稱、副名稱
    func configure(with drink: Drink) {
        drinkImageView.kf.setImage(with: drink.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        nameLabel.text = drink.name
        subNameLabel.text = drink.subName
    }
    
    // MARK: - Lifecycle Methods

    // 清空圖像與文字
    override func prepareForReuse() {
        super.prepareForReuse()
        drinkImageView.image = nil
        nameLabel.text = nil
        subNameLabel.text = nil
    }
    
}
