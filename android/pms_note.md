PMS 纪要
========

启动流程
----------------------------------------------------------------------------------------------------
```aidl

1. PackageManagerService.main() {
    2. new PackageManagerService() {
        3. 

    PackageManagerService.enableSystemUserPackages()
    
    ServiceManager.addService("package", m);
    ServiceManager.addService("package_native", pmn);
```


scanDirTracedLI for /data/app/xxx
----------------------------------------------------------------------------------------------------
### /data/app下的apk需要是已知路径

#### 异常log
```log
08-05 07:27:17.696  1645  1645 I PackageManager: /data/app/antutu_benchmark_3d changed; collecting certs
08-05 07:27:19.443  1645  1645 W PackageManager: Failed to scan /data/app/antutu_benchmark_3d: Application package com.antutu.benchmark.full not found; ignoring.
08-05 07:27:19.443  1645  1645 I PackageManager: /data/app/antutu-benchmark changed; collecting certs
08-05 07:27:20.075  1645  1645 W PackageManager: Failed to scan /data/app/antutu-benchmark: Application package com.antutu.ABenchMark not found; ignoring.
08-05 07:27:20.906  1645  1645 W PackageManager: Destroying orphaned/data/app/antutu-benchmark
08-05 07:27:20.913  1645  1645 W PackageManager: Destroying orphaned/data/app/antutu_benchmark_3d
```

#### 调用分析

当扫描的apk从mSettings中获取不到时，即known==null，抛出异常
```
1. throw PackageManagerException if known == null
2. PackageSetting known = mSettings.getPackageLPr(pkg.packageName)




```

##### throw PackageManagerException
异常抛出时`call stack`内容如下：
```
08-05 10:05:36.970  1646  1646 D bob_log_tag:  	_ [assertPackageIsValid - line:11449]   pid: 1646  thread: main  thisha: 4d3642b
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.assertPackageIsValid(PackageManagerService.java:11454)
    private void assertPackageIsValid(PackageParser.Package pkg, int policyFlags, int scanFlags)
            throws PackageManagerException {
                if (mExpectingBetter.containsKey(pkg.packageName)) {
                } else {
->                  PackageSetting known = mSettings.getPackageLPr(pkg.packageName);
                                           ^^^^^^^^^^^^^^^^^^^^^^^
                    if (known != null) {
                    } else {
                        throw new PackageManagerException(INSTALL_FAILED_INVALID_INSTALL_LOCATION,
                                "Application package " + pkg.packageName
                                + " not found; ignoring.");
    }
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.scanPackageDirtyLI(PackageManagerService.java:10726)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.scanPackageLI(PackageManagerService.java:10654)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.scanPackageInternalLI(PackageManagerService.java:9554)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.scanPackageLI(PackageManagerService.java:9270)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.scanDirLI(PackageManagerService.java:9084)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.scanDirTracedLI(PackageManagerService.java:9037)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.<init>(PackageManagerService.java:2762)
    public PackageManagerService(Context context, Installer installer,
            boolean factoryTest, boolean onlyCore) {
        synchronized (mInstallLock) {
        synchronized (mPackages) {
            if (!mOnlyCore) {
->              scanDirTracedLI(mAppInstallDir, 0, scanFlags | SCAN_REQUIRE_KNOWN, 0);
                                ^^^^^^^^^^^^^^                 ^^^^^^^^^^^^^^^^^^
                                /data/app                      需要安装的路径是已知的
    }
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.pm.PackageManagerService.main(PackageManagerService.java:2314)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.SystemServer.startBootstrapServices(SystemServer.java:585)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.SystemServer.run(SystemServer.java:389)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.server.SystemServer.main(SystemServer.java:267)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- java.lang.reflect.Method.invoke(Native Method)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:438)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	|-- com.android.internal.os.ZygoteInit.main(ZygoteInit.java:787)
08-05 10:05:36.971  1646  1646 D bob_log_tag:  	@
```

```
    PackageSetting getPackageLPr(String pkgName) {
        return mPackages.get(pkgName);
    }
```












