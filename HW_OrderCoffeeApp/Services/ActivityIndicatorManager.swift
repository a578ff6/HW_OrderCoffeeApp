//
//  ActivityIndicatorManager.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2023/12/15.
//

// MARK: - 修正版

/*
 1. 初始化的時機：
    * 原版：
        - 指示器與覆蓋層在 activityIndicator(on:backgroundColor:) 中初始化，並添加到視圖層次結構中。通常在視圖加載時調用。
    * 修正版：
        - 指示器與覆蓋層在 startLoading(on:backgroundColor:) 中初始化，並立即添加到視圖層次結構中。確保在需要時才初始化與顯示指示器。

 2. 顯示和隱藏的控制：
    * 原版：
        - 在 activityIndicator(on:backgroundColor:) 中將覆蓋層隱藏，並在  startLoading 和 stopLoading 中控制覆蓋層的顯示、隱藏。
    * 修正版：
        - 在 startLoading(on:backgroundColor:) 中添加覆蓋層與指示器到視圖中，並開始動畫; 在 stopLoading 中移除他們。
 
 3. 調用時機：
    * 原版：
        - activityIndicator(on:backgroundColor:) 通常在視圖加載時調用，然後在需要顯示指示器時調用startLoading 和 stopLoading。
    * 修正版：
        - 值機在需要顯示指示器時調用 startLoading(on:backgroundColor:)，並在請求完成後調用 stopLoading。
 */

import UIKit

/// 活動指示器管理
class ActivityIndicatorManager {
    
    static let shared = ActivityIndicatorManager()
    private var activityIndicator: UIActivityIndicatorView?
    private var overlayView: UIView?
    
    private init() {}
    
    /// - Parameters:
    ///   - view: 指示器將被添加到的 UIView。
    ///   - backgroundColor: 覆蓋層的背景顏色。
    func startLoading(on view: UIView, backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)) {
        if activityIndicator == nil {
            overlayView = UIView(frame: view.bounds)
            overlayView?.backgroundColor = backgroundColor
            overlayView?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(overlayView!)
            
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator?.startAnimating()
            
            overlayView?.addSubview(activityIndicator!)
            
            NSLayoutConstraint.activate([
                overlayView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlayView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                overlayView!.topAnchor.constraint(equalTo: view.topAnchor),
                overlayView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                activityIndicator!.centerXAnchor.constraint(equalTo: overlayView!.centerXAnchor),
                activityIndicator!.centerYAnchor.constraint(equalTo: overlayView!.centerYAnchor)
            ])
        }
    }
    
    /// 停止活動指示器
    func stopLoading() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
    
}


// MARK: - 原版
/*
import UIKit

/// 活動指示器管理
class ActivityIndicatorManager {
    
    static let shared = ActivityIndicatorManager()
    private var activityIndicator: UIActivityIndicatorView?
    private var coverView: UIView?
    
    
    /// 初始化活動指示器和覆蓋層，允許自定義覆蓋層背景顏色。
    /// - Parameters:
    ///   - view: 指示器將被添加到的 UIView。
    ///   - backgroundColor: 覆蓋層的背景顏色。
    func activityIndicator(on view: UIView, backgroundColor: UIColor = .clear) {
        coverView = UIView(frame: view.bounds)
        coverView?.backgroundColor = backgroundColor
        coverView?.isHidden = true
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.center = view.center
        activityIndicator?.hidesWhenStopped = true

        coverView?.addSubview(activityIndicator!)
        view.addSubview(coverView!)
    }
    

    /// 啟動活動指示器
    func startLoading() {
        coverView?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    /// 停止活動指示器
    func stopLoading() {
        activityIndicator?.stopAnimating()
        coverView?.isHidden = true
    }
}
*/

