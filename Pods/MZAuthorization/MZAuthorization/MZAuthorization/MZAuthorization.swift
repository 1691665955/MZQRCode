//
//  MZAuthorization.swift
//  MZAuthorization
//
//  Created by 曾龙 on 2022/7/4.
//

import UIKit

public enum MZAuthorizationType {
    case photoAddOnly       // 保存图片到本地
    case photoReadWrite     // 选择图片或保存图片
    case camera             // 相机
    case mic                // 麦克风
    case contact            // 联系人
    case event              // 日历
    case reminder           // 提醒
    case locationWhenInUse  // 定位
    case locationAlways     // 定位
    case bluetooth          // 蓝牙
}

public struct MZAuthorization {
    
    /// 获取权限
    /// - Parameters:
    ///   - type: 权限类型
    ///   - success: 获取权限成功
    ///   - failure: 获取权限失败（只有定位服务不可用时才会有回调）
    public static func requestAuth(type: MZAuthorizationType, success: @escaping () -> Void, failure: (() -> Void)? = nil) {
        switch type {
        case .photoAddOnly:
            let status = MZAuthorizationTool.photoAuthorizationStatus(level: .addOnly)
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requestPhotoAuthorization(level: .addOnly) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: .photoAddOnly)
            case .authorized, .limited:
                success()
            default :
                break
            }
        case .photoReadWrite:
            let status = MZAuthorizationTool.photoAuthorizationStatus(level: .readWrite)
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requestPhotoAuthorization(level: .readWrite) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: .photoReadWrite)
            case .authorized, .limited:
                success()
            default :
                break
            }
        case .camera:
            let status = MZAuthorizationTool.cameraAuthorizationStatus()
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requsetCameraAuthorization { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: .camera)
            case .authorized:
                success()
            default:
                break
            }
        case .mic:
            let status = MZAuthorizationTool.micAuthorizationStatus()
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requestMicAuthorization { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: .mic)
            case .authorized:
                success()
            default:
                break
            }
        case .contact:
            let status = MZAuthorizationTool.contactAuthorizationStatus()
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requestContactAuthorization { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: .contact)
            case .authorized:
                success()
            default:
                break
            }
        case .event:
            let status = MZAuthorizationTool.calendarAuthorizationStatus(type: .event);
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requestCalendarAuthorization(type: .event) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: .event)
            case .authorized:
                success()
            default:
                break
            }
        case .reminder:
            let status = MZAuthorizationTool.calendarAuthorizationStatus(type: .reminder);
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requestCalendarAuthorization(type: .reminder) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: .reminder)
            case .authorized:
                success()
            default:
                break
            }
        case .locationWhenInUse, .locationAlways:
            let status = MZAuthorizationTool.locationAuthorizationStatus()
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requestLocationAuthorization(level: type == .locationWhenInUse ? .whenInUse : .always ) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: type)
            case .authorized, .limited:
                success()
            case .disable:
                if failure != nil {
                    failure!()
                }
            default:
                break
            }
        case .bluetooth:
            let status = MZAuthorizationTool.bluetoothAuthorizationStatus()
            switch status {
            case .notDetermined:
                MZAuthorizationTool.requestBluetoothAuthorization { granted in
                    if granted {
                        DispatchQueue.main.async {
                            success()
                        }
                    }
                }
            case .denied:
                showDeniedAlert(type: type)
            case .authorized, .limited:
                success()
            case .disable:
                if failure != nil {
                    failure!()
                }
            default:
                break
            }
        }
    }
    
    
    /// 展示授权弹框
    /// - Parameter type: 授权类型
    public static func showDeniedAlert(type: MZAuthorizationType) {
        let appName = (Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? Bundle.main.infoDictionary!["CFBundleName"]) as! String
        var title = ""
        var description = ""
        switch type {
        case .photoAddOnly:
            title = "PhotoTitle_add"
            description = Bundle.main.infoDictionary!["NSPhotoLibraryAddUsageDescription"] as! String
        case .photoReadWrite:
            title = "PhotoTitle_all"
            description = Bundle.main.infoDictionary!["NSPhotoLibraryUsageDescription"] as! String
        case .camera:
            title = "CameraTitle"
            description = Bundle.main.infoDictionary!["NSCameraUsageDescription"] as! String
        case .mic:
            title = "MicTitle"
            description = Bundle.main.infoDictionary!["NSMicrophoneUsageDescription"] as! String
        case .contact:
            title = "ContactTitle"
            description = Bundle.main.infoDictionary!["NSContactsUsageDescription"] as! String
        case .event:
            title = "EventTitle"
            description = Bundle.main.infoDictionary!["NSCalendarsUsageDescription"] as! String
        case .reminder:
            title = "ReminderTitle"
            description = Bundle.main.infoDictionary!["NSRemindersUsageDescription"] as! String
        case .locationWhenInUse:
            title = "LocationTitle"
            description = Bundle.main.infoDictionary!["NSLocationWhenInUseUsageDescription"] as! String
        case .locationAlways:
            title = "LocationTitle"
            description = Bundle.main.infoDictionary!["NSLocationAlwaysUsageDescription"] as! String
        case .bluetooth:
            title = "BleTitle"
            description = Bundle.main.infoDictionary!["NSBluetoothAlwaysUsageDescription"] as! String
        }
        let alert = UIAlertController(title: String(format: title.localized(), appName) , message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "PermissionGo".localized(), style: .default, handler: { _ in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } else {
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
        }))
        alert.addAction(UIAlertAction(title: "PermissionNot".localized(), style: .cancel, handler: nil))
        currentViewController()?.present(alert, animated: true)
    }
    
    private static func currentWindow() -> UIWindow? {
        let app = UIApplication.shared
        if let window = app.delegate?.window {
            return window
        } else {
            return app.keyWindow
        }
    }
    
    private static func currentViewController() -> UIViewController? {
        guard let controller = currentWindow()?.rootViewController else {
            return nil
        }
        return self.currentViewControllerFrom(controller)
    }
    
    private static func currentViewControllerFrom(_ root: UIViewController) -> UIViewController {
        let currentViewController: UIViewController
        if root.presentedViewController != nil {
            return self.currentViewControllerFrom(root.presentedViewController!)
        }
        if root.isKind(of: UITabBarController.classForCoder()) {
            currentViewController = self.currentViewControllerFrom((root as! UITabBarController).selectedViewController!)
        } else if root.isKind(of: UINavigationController.classForCoder()) {
            currentViewController = self.currentViewControllerFrom((root as! UINavigationController).visibleViewController!)
        } else {
            currentViewController = root
        }
        return currentViewController
    }
}
