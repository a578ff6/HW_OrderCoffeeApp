//
//  OrderItemCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/7/4.
//

/*
 ## 固定 sizeLabel 寬度：
        - 固定 sizeLabel 寬度，確保無論內容多長，quantityLabel 都能保持固定位置。
        - 設置 sizeLabel 的 numberOfLines ，並設置 adjustsFontSizeToFitWidth 和 minimumScaleFactor，以確保文字能縮小以適應固定寬度。
        - 確保 sizeLabel 和 quantityLabel 之間的間距固定，並且 quantityLabel 的位置不會受到 sizeLabel 內容長度的影響。
 
 -----------------------------------------------------------------------------------------------
 
 ## OrderItemCollectionViewCell 筆記：
 
    * 功能：
        - 顯示訂單中的飲品項目，包含名稱、子名稱、尺寸、數量和價格等資訊。
        - 提供刪除訂單項目的按鈕。

    * 視圖設置：
        - 透過 UIImageView 和 UILabel 顯示飲品相關的圖片和文字。
        - 使用多個 UIStackView 組織各個 UI 元素，。
 
    * 元件重設：
        - 在 prepareForReuse 方法中，重設圖片和文字內容，以確保在 Cell 重複使用時不會顯示舊的資料。
 
    * 刪除功能：
        - 使用刪除按鈕並設置 deleteAction 閉包，在按下按鈕時執行對應的刪除行為。
 */

// MARK: - 整理版本
/*
 import UIKit

 class OrderItemCollectionViewCell: UICollectionViewCell {
     
     static let reuseIdentifier = "OrderItemCollectionViewCell"
     
     let drinkImageView = OrderItemCollectionViewCell.createDrinkImageView()
     let titleLabel = OrderItemCollectionViewCell.createLabel(fontSize: 17, numberOfLines: 1, scaleFactor: 0.7)
     let subtitleNameLabel = OrderItemCollectionViewCell.createLabel(fontSize: 13, numberOfLines: 2, textColor: .gray, scaleFactor: 0.5)
     let sizeLabel = OrderItemCollectionViewCell.createLabel(fontSize: 14, textColor: UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1), scaleFactor: 0.5)
     let separatorLabel = OrderItemCollectionViewCell.createSeparatorLabel()
     let quantityImageView = OrderItemCollectionViewCell.createQuantityImageView()
     let quantityLabel = OrderItemCollectionViewCell.createLabel(fontSize: 14)
     let priceLabel = OrderItemCollectionViewCell.createLabel(fontSize: 15, textAlignment: .right)
     let deleteButton = OrderItemCollectionViewCell.createDeleteButton(target: self, action: #selector(deleteButtonTapped))
     let bottomLineView = OrderItemCollectionViewCell.createBottomLineView()

     let titleAndSubtitleStackView = OrderItemCollectionViewCell.createVerticalStackView(spacing: 2)
     let sizeAndQuantityStackView = OrderItemCollectionViewCell.createHorizontalStackView(spacing: 8)
     let priceAndDeleteStackView = OrderItemCollectionViewCell.createVerticalStackView(spacing: 2, alignment: .center)
     
     var deleteAction: (() -> Void)?
     
     override init(frame: CGRect) {
         super.init(frame: frame)
         setupViews()
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         fatalError("init(coder:) has not been implemented")
     }
     
     private static func createDrinkImageView() -> UIImageView {
         let imageView = UIImageView()
         imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.contentMode = .scaleAspectFit
         imageView.layer.borderWidth = 2
         imageView.layer.masksToBounds = true
         imageView.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
         imageView.layer.cornerRadius = 15
         imageView.clipsToBounds = true
         return imageView
     }
     
     private static func createLabel(fontSize: CGFloat, numberOfLines: Int = 1, textColor: UIColor = .black, scaleFactor: CGFloat = 1.0, textAlignment: NSTextAlignment = .left) -> UILabel {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.font = UIFont.systemFont(ofSize: fontSize)
         label.numberOfLines = numberOfLines
         label.textColor = textColor
         label.adjustsFontSizeToFitWidth = true
         label.minimumScaleFactor = scaleFactor
         label.textAlignment = textAlignment
         return label
     }
     
     private static func createSeparatorLabel() -> UILabel {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.text = "|"
         label.font = UIFont.systemFont(ofSize: 14)
         label.textColor = .gray
         return label
     }
     
     private static func createQuantityImageView() -> UIImageView {
         let imageView = UIImageView(image: UIImage(systemName: "mug.fill"))
         imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.tintColor = UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1)
         return imageView
     }
     
     /// 底線
     private static func createBottomLineView() -> UIView {
         let view = UIView()
         view.translatesAutoresizingMaskIntoConstraints = false
         view.backgroundColor = .lightGray
         return view
     }
     
     private static func createDeleteButton(target: Any?, action: Selector) -> UIButton {
         let button = UIButton(type: .system)
         button.translatesAutoresizingMaskIntoConstraints = false
         let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
         let largeBoldDoc = UIImage(systemName: "trash.circle.fill", withConfiguration: largeConfig)
         button.setImage(largeBoldDoc, for: .normal)
         button.addTarget(target, action: action, for: .touchUpInside)
         button.widthAnchor.constraint(equalToConstant: 44).isActive = true
         button.heightAnchor.constraint(equalToConstant: 44).isActive = true
         return button
     }
     
     private static func createVerticalStackView(spacing: CGFloat, alignment: UIStackView.Alignment = .leading, distribution: UIStackView.Distribution = .fillProportionally) -> UIStackView {
         let stackView = UIStackView()
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.axis = .vertical
         stackView.spacing = spacing
         stackView.distribution = distribution
         stackView.alignment = alignment
         return stackView
     }
     
     private static func createHorizontalStackView(spacing: CGFloat, alignment: UIStackView.Alignment = .leading, distribution: UIStackView.Distribution = .fill) -> UIStackView {
         let stackView = UIStackView()
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.axis = .horizontal
         stackView.spacing = spacing
         stackView.distribution = distribution
         stackView.alignment = alignment
         return stackView
     }
     
     private func setupViews() {
         contentView.addSubview(drinkImageView)
         contentView.addSubview(titleAndSubtitleStackView)
         contentView.addSubview(priceAndDeleteStackView)
         contentView.addSubview(bottomLineView)
         
         titleAndSubtitleStackView.addArrangedSubview(titleLabel)
         titleAndSubtitleStackView.addArrangedSubview(subtitleNameLabel)
         titleAndSubtitleStackView.addArrangedSubview(sizeAndQuantityStackView)
         
         sizeAndQuantityStackView.addArrangedSubview(sizeLabel)
         sizeAndQuantityStackView.addArrangedSubview(separatorLabel)
         
         let quantityStackView = UIStackView(arrangedSubviews: [quantityImageView, quantityLabel])
         quantityStackView.axis = .horizontal
         quantityStackView.spacing = 4
         sizeAndQuantityStackView.addArrangedSubview(quantityStackView)
         
         priceAndDeleteStackView.addArrangedSubview(priceLabel)
         priceAndDeleteStackView.addArrangedSubview(deleteButton)
         
         NSLayoutConstraint.activate([
             drinkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             drinkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
             drinkImageView.widthAnchor.constraint(equalToConstant: 80),
             drinkImageView.heightAnchor.constraint(equalTo: drinkImageView.widthAnchor),
             
             titleAndSubtitleStackView.topAnchor.constraint(equalTo: drinkImageView.topAnchor),
             titleAndSubtitleStackView.leadingAnchor.constraint(equalTo: drinkImageView.trailingAnchor, constant: 15),
             titleAndSubtitleStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceAndDeleteStackView.leadingAnchor, constant: -15),
             titleAndSubtitleStackView.bottomAnchor.constraint(equalTo: drinkImageView.bottomAnchor),  // 對齊圖片底部
             
             sizeLabel.widthAnchor.constraint(equalToConstant: 80),  // 固定 sizeLabel 寬度
             
             sizeAndQuantityStackView.leadingAnchor.constraint(equalTo: titleAndSubtitleStackView.leadingAnchor),
             sizeAndQuantityStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceAndDeleteStackView.leadingAnchor, constant: -15),
             
             quantityImageView.widthAnchor.constraint(equalToConstant: 20),
             quantityImageView.heightAnchor.constraint(equalTo: quantityImageView.widthAnchor),
             
             priceAndDeleteStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             priceAndDeleteStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
             priceAndDeleteStackView.widthAnchor.constraint(equalToConstant: 80),
             
             bottomLineView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
             bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
             bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
             bottomLineView.heightAnchor.constraint(equalToConstant: 1)
         ])
         
         titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
         subtitleNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
         priceLabel.setContentHuggingPriority(.required, for: .horizontal)
         priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
     }
     
     func configure(with orderItem: OrderItem) {
         drinkImageView.kf.setImage(with: orderItem.drink.imageUrl)
         titleLabel.text = orderItem.drink.name
         subtitleNameLabel.text = orderItem.drink.subName
         sizeLabel.text = "\(orderItem.size)"
         quantityLabel.text = "\(orderItem.quantity)"
         priceLabel.text = "\(orderItem.price) 元/杯"
     }
     
     @objc private func deleteButtonTapped() {
         deleteAction?()
     }
 }
*/


// MARK: - 測試用
import UIKit

class OrderItemCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "OrderItemCollectionViewCell"
    
    // MARK: - UI Elements

    let drinkImageView = OrderItemCollectionViewCell.createDrinkImageView()
    let titleLabel = OrderItemCollectionViewCell.createLabel(fontSize: 17, numberOfLines: 1, scaleFactor: 0.7)
    let subtitleNameLabel = OrderItemCollectionViewCell.createLabel(fontSize: 13, numberOfLines: 2, textColor: .gray, scaleFactor: 0.5)
    let sizeLabel = OrderItemCollectionViewCell.createLabel(fontSize: 14, textColor: UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1), scaleFactor: 0.5)
    let separatorLabel = OrderItemCollectionViewCell.createSeparatorLabel()
    let quantityImageView = OrderItemCollectionViewCell.createQuantityImageView()
    let quantityLabel = OrderItemCollectionViewCell.createLabel(fontSize: 14)
    let priceLabel = OrderItemCollectionViewCell.createLabel(fontSize: 15, textAlignment: .right)
    let deleteButton = OrderItemCollectionViewCell.createDeleteButton(target: self, action: #selector(deleteButtonTapped))
    let bottomLineView = OrderItemCollectionViewCell.createBottomLineView()

    let titleAndSubtitleStackView = OrderItemCollectionViewCell.createVerticalStackView(spacing: 2)
    let sizeAndQuantityStackView = OrderItemCollectionViewCell.createHorizontalStackView(spacing: 8)
    let priceAndDeleteStackView = OrderItemCollectionViewCell.createVerticalStackView(spacing: 2, alignment: .center)
    
    var deleteAction: (() -> Void)?
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Factory Methods

    /// 建立飲品圖片視圖
    private static func createDrinkImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        return imageView
    }
    
    /// 建立標籤視圖
    private static func createLabel(fontSize: CGFloat, numberOfLines: Int = 1, textColor: UIColor = .black, scaleFactor: CGFloat = 1.0, textAlignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.numberOfLines = numberOfLines
        label.textColor = textColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = scaleFactor
        label.textAlignment = textAlignment
        return label
    }
    
    /// 建立分隔符號標籤
    private static func createSeparatorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "|"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }
    
    /// 建立數量圖片視圖
    private static func createQuantityImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: "mug.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(red: 0, green: 112/255, blue: 74/255, alpha: 1)
        return imageView
    }
    
    /// 建立底部分隔線視圖
    private static func createBottomLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightWhiteGray
        return view
    }
    
    /// 建立刪除按鈕
    private static func createDeleteButton(target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "trash.circle.fill", withConfiguration: largeConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    /// 建立垂直堆疊視圖
    private static func createVerticalStackView(spacing: CGFloat, alignment: UIStackView.Alignment = .leading, distribution: UIStackView.Distribution = .fillProportionally) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.alignment = alignment
        return stackView
    }
    
    /// 建立水平堆疊視圖
    private static func createHorizontalStackView(spacing: CGFloat, alignment: UIStackView.Alignment = .leading, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.alignment = alignment
        return stackView
    }
    
    // MARK: - Setup Methods

    /// 設置各視圖元件並配置約束
    private func setupViews() {
        contentView.addSubview(drinkImageView)
        contentView.addSubview(titleAndSubtitleStackView)
        contentView.addSubview(priceAndDeleteStackView)
        contentView.addSubview(bottomLineView)
        
        titleAndSubtitleStackView.addArrangedSubview(titleLabel)
        titleAndSubtitleStackView.addArrangedSubview(subtitleNameLabel)
        titleAndSubtitleStackView.addArrangedSubview(sizeAndQuantityStackView)
        
        sizeAndQuantityStackView.addArrangedSubview(sizeLabel)
        sizeAndQuantityStackView.addArrangedSubview(separatorLabel)
        
        let quantityStackView = UIStackView(arrangedSubviews: [quantityImageView, quantityLabel])
        quantityStackView.axis = .horizontal
        quantityStackView.spacing = 4
        sizeAndQuantityStackView.addArrangedSubview(quantityStackView)
        
        priceAndDeleteStackView.addArrangedSubview(priceLabel)
        priceAndDeleteStackView.addArrangedSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            drinkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            drinkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            drinkImageView.widthAnchor.constraint(equalToConstant: 80),
            drinkImageView.heightAnchor.constraint(equalTo: drinkImageView.widthAnchor),
            
            titleAndSubtitleStackView.topAnchor.constraint(equalTo: drinkImageView.topAnchor),
            titleAndSubtitleStackView.leadingAnchor.constraint(equalTo: drinkImageView.trailingAnchor, constant: 15),
            titleAndSubtitleStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceAndDeleteStackView.leadingAnchor, constant: -15),
            titleAndSubtitleStackView.bottomAnchor.constraint(equalTo: drinkImageView.bottomAnchor),  // 對齊圖片底部
            
            sizeLabel.widthAnchor.constraint(equalToConstant: 80),  // 固定 sizeLabel 寬度
            
            sizeAndQuantityStackView.leadingAnchor.constraint(equalTo: titleAndSubtitleStackView.leadingAnchor),
            sizeAndQuantityStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceAndDeleteStackView.leadingAnchor, constant: -15),
            
            quantityImageView.widthAnchor.constraint(equalToConstant: 20),
            quantityImageView.heightAnchor.constraint(equalTo: quantityImageView.widthAnchor),
            
            priceAndDeleteStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceAndDeleteStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            priceAndDeleteStackView.widthAnchor.constraint(equalToConstant: 80),
            
            bottomLineView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subtitleNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    // MARK: - Configure Method

    /// 設置 Cell 的內容
    /// - Parameter orderItem: 包含訂單飲品的詳細資訊
    func configure(with orderItem: OrderItem) {
        drinkImageView.kf.setImage(with: orderItem.drink.imageUrl)
        titleLabel.text = orderItem.drink.name
        subtitleNameLabel.text = orderItem.drink.subName
        sizeLabel.text = "\(orderItem.size)"
        quantityLabel.text = "\(orderItem.quantity)"
        priceLabel.text = "\(orderItem.price) 元/杯"
    }
    
    // MARK: - Lifecycle Methods

    override func prepareForReuse() {
        super.prepareForReuse()
        drinkImageView.image = nil
        titleLabel.text = nil
        subtitleNameLabel.text = nil
        sizeLabel.text = nil
        quantityLabel.text = nil
        priceLabel.text = nil
    }
    
    // MARK: - Button Action
    
    /// 刪除按鈕觸發事件
    @objc private func deleteButtonTapped() {
        deleteAction?()
    }
}


