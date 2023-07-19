# MZAuthorization
Swift应用权限授权申请统一处理

#### Cocoapods 引入
```
pod 'MZAuthorization', '~> 0.0.6'
```

### 权限类型

```
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
    Case bluetooth	    // 蓝牙
}
```

### 统一获取权限

```
// 获取相册写入权限
MZAuthorization.requestAuth(type: .photoAddOnly) {
    print("相册添加权限打开成功")

    // 使用该方法保存图片只需请求写入权限（photoAddOnly）
    UIImageWriteToSavedPhotosAlbum(UIImage.init(named: "1")!, self, #selector(self.didFinishSavingImage(image:error:contextInfo:)), nil)
}

// 获取相册权限
MZAuthorization.requestAuth(type: .photoReadWrite) {
    print("相册选择权限打开成功")

    // 使用该方法保存图片需请求读取写入权限（photoReadWrite）
    MZPhotoAsset.saveImage(image: UIImage.init(named: "1")!, collectionName: "MZAuthorization") { success in
        print(success ? "保存成功" : "保存失败")
    }
}

// 获取相机权限
MZAuthorization.requestAuth(type: .camera) {
    print("相机权限打开成功")
}

// 获取麦克风权限
MZAuthorization.requestAuth(type: .mic) {
    print("麦克风权限打开成功")
}

// 获取通讯录权限
MZAuthorization.requestAuth(type: .contact) {
    print("通讯录权限打开成功")
}

// 获取日历权限
MZAuthorization.requestAuth(type: .event) {
    print("日历权限打开成功")
}

// 获取提醒权限
MZAuthorization.requestAuth(type: .reminder) {
    print("提醒权限打开成功")
}

// 获取定位权限
MZAuthorization.requestAuth(type: .locationWhenInUse) {
    print("定位权限打开成功")
} failure: {
    print("请打开定位")
}

// 后台获取定位
MZAuthorization.requestAuth(type: .locationAlways) {
    print("定位权限打开成功")

    self.locationManager = CLLocationManager()
    self.locationManager?.delegate  = self
    self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager?.allowsBackgroundLocationUpdates = true
    self.locationManager?.startUpdatingLocation()
} failure: {
    print("请打开定位")
}

// 获取蓝牙权限
MZAuthorization.requestAuth(type: .bluetooth) {
    print("蓝牙权限打开成功")
}

```

### 单独获取权限状态、单独获取权限授权

参考`MZAuthorizationTool`类方法
