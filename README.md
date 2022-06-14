# BDLiveDemo_iOS介绍

BDLiveDemo现有四个Demo，这四个Demo分别从不同方面介绍如何接入BDLive。

- SimpleViewer：快速接入BDLive
- Player：接入播放器组件
- FloatingPlayer：接入浮窗播放器组件
- HybridViewer：接入SDK组件，并同时配合业务UI组成的直播间

# 如何运行

> 这里以SimpleViewer为例，另外几个 Demo 操作方法相同。

1. 在终端中打开 SimpleViewer 文件夹，并执行 **pod install**。
2. 获取 TTSDK License。获取方法请参考 [获取License文件](https://www.volcengine.com/docs/6469/81443)。
3. 添加 TTSDK 的 License 文件到工程中。

- License 作为使用 TTSDK 对应模块的鉴权凭证，需要正确设置，将您获取到的 License 文件拖入工程，操作后的截图如下所示。

![License File Path](./images/licenseFilePath.png)

4. 修改 Demo 的 `AppDelegate.m` 中 `-initTTSDK` 方法，填入 的初始化参数：BundleID、AppID、LicenseFilePath（如上图中的 lic 文件，应填入 "**licenseFilePath**"）、BundleID。

```
    TTSDKConfiguration *configuration = [TTSDKConfiguration defaultConfigurationWithAppID:@"<#AppID#>"];
    configuration.licenseFilePath = [[NSBundle mainBundle] pathForResource:@"<#licenseFilePath#>" ofType:@"lic"];
    configuration.bundleID = @"<#bundleID#>";
```

> 注意:
>
> 传入 SDK 的初始化参数：BundleID、AppID 与 License 文件有严格的对应关系。
同时需要保证您传入 SDK 的 BundleID 和工程配置的 BundleID 一致，否则会出现鉴权失败的问题。

5. 打开 SimpleViewer.xcworkspace 编译运行。

# SDK集成文档

[iOS 观播 SDK](https://www.volcengine.com/docs/6669/101259)
