# WebView Force Close

## MissingWebViewPackageException

```verilog
01-02 03:05:31.504 25622 25622 E AndroidRuntime: Caused by: android.util.AndroidRuntimeException: android.webkit.WebViewFactory$MissingWebViewPackageException: Failed to load WebView provider: No WebView installed
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.webkit.WebViewFactory.getProviderClass(WebViewFactory.java:423)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.webkit.WebViewFactory.getProvider(WebViewFactory.java:194)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.webkit.WebView.getFactory(WebView.java:2530)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.webkit.WebView.ensureProviderCreated(WebView.java:2525)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.webkit.WebView.setOverScrollMode(WebView.java:2590)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.view.View.<init>(View.java:4574)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.view.View.<init>(View.java:4706)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.view.ViewGroup.<init>(ViewGroup.java:597)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.widget.AbsoluteLayout.<init>(AbsoluteLayout.java:55)
01-02 03:05:31.504 25622 25622 E AndroidRuntime: 	at android.webkit.WebView.<init>(WebView.java:643)
01-02 03:05:31.505 25622 25622 E AndroidRuntime: 	at android.webkit.WebView.<init>(WebView.java:588)
01-02 03:05:31.505 25622 25622 E AndroidRuntime: 	at android.webkit.WebView.<init>(WebView.java:571)
01-02 03:05:31.505 25622 25622 E AndroidRuntime: 	at android.webkit.WebView.<init>(WebView.java:558)
01-02 03:05:31.505 25622 25622 E AndroidRuntime: 	... 28 more
01-02 03:05:31.505 25622 25622 E AndroidRuntime: Caused by: android.webkit.WebViewFactory$MissingWebViewPackageException: Failed to load WebView provider: No WebView installed
01-02 03:05:31.505 25622 25622 E AndroidRuntime: 	at android.webkit.WebViewFactory.getWebViewContextAndSetProvider(WebViewFactory.java:319)
01-02 03:05:31.505 25622 25622 E AndroidRuntime: 	at android.webkit.WebViewFactory.getProviderClass(WebViewFactory.java:383)
01-02 03:05:31.505 25622 25622 E AndroidRuntime: 	... 40 more
01-02 03:05:31.509 17549 17633 W ActivityManager:   Force finishing activity com.android.htmlviewer/.HTMLViewerActivity

```

### 描摹1

android很多应用依赖于webview组件功能，当系统没有改组件时，与之依赖的应用就会crash。系统通过解析`config_webview_packages.xml`文件内容，获取`webview`组件信息。`SystemImpl.java`中的`SystemImpl()`方法从`com.android.internal.R.xml.config_webview_packages`中获取webview信息后会构造`WebViewProviderInfo`对象，并将其添加到当前系统中，用`SystemImpl.mWebViewProviderPackages`类变量来保存

### 描摹2

[frameworks](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/)/[base](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/)/[services](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/)/[core](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/)/[java](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/)/[com](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/)/[android](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/android/)/[server](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/android/server/)/[webkit](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/android/server/webkit/)/[SystemImpl.java](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/android/server/webkit/SystemImpl.java)中的`SystemImpl()`方法从`com.android.internal.R.xml.config_webview_packages`中读取webview的配置信息，并将其保存在`mWebViewProviderPackages`中。

当发现`No WebView installed`的crash时，将设备中的`frameworks-res.apk` pull到本地，反编译资源文件，查看config_webview_packages.xml中配置的webview包名是否已经安装(用`pm -lf`来确认)。

### 调用流程

* `frameworks/base/core/res/res/xml/config_webview_packages.xml`的内容

```xml
<?xml version="1.0" encoding="utf-8"?>
<webviewproviders>
    <!-- The default WebView implementation -->
    <webviewprovider description="Android WebView" packageName="com.google.android.webview" availableByDefault="true">
    </webviewprovider>
</webviewproviders>
```

* [frameworks](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/)/[base](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/)/[services](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/)/[core](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/)/[java](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/)/[com](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/)/[android](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/android/)/[server](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/android/server/)/[webkit](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/android/server/webkit/)/[SystemImpl.java](http://opengrok.pt.xiaomi.com/opengrok/xref/v10-p-cepheus-dev/frameworks/base/services/core/java/com/android/server/webkit/SystemImpl.java)中的`SystemImpl()`方法

```java
77    private SystemImpl() {
...
83        try {
84            parser = AppGlobals.getInitialApplication().getResources().getXml(
85                    com.android.internal.R.xml.config_webview_packages);
...
87            while(true) {
...
108                    WebViewProviderInfo currentProvider = new WebViewProviderInfo(
109                            packageName, description, availableByDefault, isFallback,
110                            readSignatures(parser));
...
128                    webViewProviders.add(currentProvider);
129                }
133            }
134        } catch (...) {
136        } finally {
138        }
...
147        mWebViewProviderPackages =
148                webViewProviders.toArray(new WebViewProviderInfo[webViewProviders.size()]);
149    }
```

`开发者选项`中验证webview

```bash
adb shell am start -a com.android.settings.APPLICATION_DEVELOPMENT_SETTINGS
# 运行上面命令进入开发者选项，里面有一个"WebView实现"选项，点击查看当前系统是否有webview组件
```

