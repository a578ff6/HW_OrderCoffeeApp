//
//  ShareManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/12.
//


/*

 ## ShareManager：

    - 功能：負責管理飲品資訊的分享功能，包括飲品名稱、描述及使用者選取的尺寸資訊，並支援分享圖片。
 
    * 邏輯流程：
        1. 生成分享內容文字，包含飲品名稱、描述及尺寸資訊。
        2. 使用 Kingfisher 非同步加載飲品圖片，並將其添加到分享項目。
        3. 初始化 UIActivityViewController，顯示分享選項。
 
    * 方法概述：
        - share(drink:selectedSize:sizeInfo:from:)： 主方法，整合文字與圖片後觸發分享操作。從指定的視圖控制器中呈現分享頁面。
        - generateShareText(drink:selectedSize:sizeInfo:)： 生成分享文字內容，根據飲品資訊與選取的尺寸資訊動態組合。
        - downloadImageAndShare(drink:itemsToShare:from:)： 下載飲品圖片，並在成功後將圖片添加到分享項目。如果圖片下載失敗，則提示用戶圖片無法下載，但仍可分享文字內容。
        - presentShareController(itemsToShare:in:)： 初始化 UIActivityViewController，並顯示分享頁面。
 
    * 資料處理：
        - 文字處理： 在 generateShareText 方法中，根據飲品的基本資訊（名稱、描述）及選取的尺寸資訊生成完整的分享文字。這些資訊包含了使用者選取的尺寸、價格、卡路里、咖啡因等詳細資料。
        - 圖片處理： 使用 Kingfisher 來下載飲品圖片。在 downloadImageAndShare 方法中，將圖片與文字一同整合進分享內容。如果圖片下載失敗，則顯示錯誤訊息，並僅分享文字內容。

    * 主要流程：
        - share()： 整合分享文字與圖片並觸發分享功能。
        - downloadImageAndShare()： 非同步加載圖片，將其加入分享項目，並根據結果展示分享控制器。
        - generateShareText()： 生成分享文字，處理基本資訊和尺寸資訊的組合。
        - presentShareController()： 顯示分享頁面，允許使用者分享內容。
 
 --------------------------------------------------------------------------------------------------------------------------------
 
 ## rightBarButtonItem 的應用重點筆記：

    * 功能與作用：
        - rightBarButtonItem 是 UINavigationItem 的屬性，用來在導覽列的右上角放置一個按鈕或操作項目。
        - 可以將 rightBarButtonItem 用於 UI 操作，例如設置分享按鈕、儲存按鈕等。
 
    & 在 setupShareButton 中的應用：
        * 作用：
            - 將分享按鈕添加到 DrinkDetailViewController 的導覽列右上角，並設置其點擊事件。
        * 具體使用：
            - navigationItem.rightBarButtonItem = shareButton 將一個 UIBarButtonItem（分享按鈕）設置到右上角，讓使用者可以點擊按鈕來觸發分享功能。
            - 點擊該按鈕後，會執行 shareDrinkInfo 方法，進而調用 ShareManager 來處理分享邏輯。
 
    & 在 presentShareController 中的應用：
        * 作用：
            - 當分享彈窗顯示時，指定彈窗從 rightBarButtonItem 位置彈出。
        * 具體使用：
            - activityViewController.popoverPresentationController?.barButtonItem = viewController.navigationItem.rightBarButtonItem
              確保分享彈窗在 iPad 或大屏幕設備上從右上角的按鈕處彈出，這樣提供了更好的 UI 體驗。
 
    & 關鍵點：
        - UI 設置： 在 setupShareButton 中，rightBarButtonItem 用來設置具體的按鈕（例如分享按鈕）。
        - 彈窗定位： 在 presentShareController 中，rightBarButtonItem 用來確保 UIActivityViewController（分享彈窗）從該按鈕位置彈出。
 */

import UIKit
import Kingfisher

/// 管理分享功能
class ShareManager {
    
    // MARK: - Singleton Instance

    static let shared = ShareManager()
    
    private init() {}

    // MARK: - Public Methods

    /// 執行分享邏輯，將飲品的名稱、描述及選取的尺寸資訊分享出去
    /// - Parameters:
    ///   - drink: 要分享的飲品資料
    ///   - selectedSize: 使用者選擇的飲品尺寸
    ///   - sizeInfo: 相關的尺寸資訊（價格、咖啡因、卡路里等）
    ///   - viewController: 從哪個視圖控制器呈現分享介面
    func share(drink: Drink, selectedSize: String?, sizeInfo: SizeInfo?, from viewController: UIViewController) {
        let shareText = generateShareText(drink: drink, selectedSize: selectedSize, sizeInfo: sizeInfo)
        var itemsToShare: [Any] = [shareText]
        downloadImageAndShare(drink: drink, itemsToShare: itemsToShare, from: viewController)
    }
    
    // MARK: - Private Methods

    /// 生成分享的文字內容
    /// - Parameters:
    ///   - drink: 需要分享的飲品物件
    ///   - selectedSize: 使用者選取的尺寸
    ///   - sizeInfo: 尺寸相關資訊
    /// - Returns: 包含飲品名稱、描述與尺寸資訊的完整文字內容
    private func generateShareText(drink: Drink, selectedSize: String?, sizeInfo: SizeInfo?) -> String {
        let drinkName = drink.name
        let drinkSubName = drink.subName
        let drinkDescription = drink.description
        
        // 基本飲品訊息
        var shareText = "\(drinkName) (\(drinkSubName)): \(drinkDescription)"
        
        // 如果有選取尺寸，將尺寸資訊加入分享內容
        if let selectedSize = selectedSize, let sizeInfo = sizeInfo {
            let sizeDetails = """
              \n選取的尺寸： \(selectedSize)
              價格： \(sizeInfo.price) ($)
              咖啡因： \(sizeInfo.caffeine) (mg)
              卡路里： \(sizeInfo.calories) (Cal)
              糖分： \(sizeInfo.sugar) (g)
              """
            shareText += sizeDetails
        }
        
        return shareText
    }
    
    /// 加載飲品圖片並進行分享
    /// - Parameters:
    ///   - drink: 需要分享的飲品物件
    ///   - itemsToShare: 已準備好的分享項目（包含文字）
    ///   - viewController: 要呈現分享頁面的控制器
    private func downloadImageAndShare(drink: Drink, itemsToShare: [Any], from viewController: UIViewController) {
        KingfisherManager.shared.retrieveImage(with: drink.imageUrl) { result in
            var finalItemsToShare = itemsToShare
            
            switch result {
            case .success(let value):
                finalItemsToShare.append(value.image)
            case .failure(let error):
                print("圖片下載失敗: \(error.localizedDescription)")
                AlertService.showAlert(withTitle: "圖片加載失敗", message: "無法下載圖片，但依然可以分享文字內容。", inViewController: viewController)
            }
            
            self.presentShareController(itemsToShare: finalItemsToShare, in: viewController)
        }
    }
    
    /// 初始化並呈現分享控制器，顯示分享選項。
    /// - Parameters:
    ///   - itemsToShare: 要分享的項目集合
    ///   - viewController: 當前的視圖控制器，用來顯示分享頁面
    private func presentShareController(itemsToShare: [Any], in viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = viewController.navigationItem.rightBarButtonItem
        
        // 呈現分享頁面
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
}
