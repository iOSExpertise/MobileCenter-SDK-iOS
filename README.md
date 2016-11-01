[![Build Status](https://www.bitrise.io/app/e5b1a2ef546331fb.svg?token=Orwi_AVAExLTuN1ZAzvbFQ&branch=develop)](https://www.bitrise.io/app/e5b1a2ef546331fb)

# Sonoma SDK for iOS

## Introduction

The Sonoma iOS SDK lets you add Sonoma services to your iOS application.

The SDK is currently in private beta release and supports the following services:

1. **Analytics**: Sonoma Analytics helps you understand user behavior and customer engagement to improve your iOS app. The SDK automatically captures session count and device properties like model, OS version etc. You can define your own custom events to measure things that matter to your business. All the information captured is available in the Sonoma portal for you to analyze the data.

2. **Crashes**: The Sonoma SDK will automatically generate a crash log every time your app crashes. The log is first written to the device's storage and when the user starts the app again, the crash report will be forwarded to Sonoma. Collecting crashes works for both beta and live apps, i.e. those submitted to App Store. Crash logs contain viable information for you to help resolve the issue. 

This document contains the following sections:

1. [Prerequisites](#1-prerequisites)
2. [Add Sonoma SDK modules](#2-add-sonoma-sdk-modules)
3. [Start the SDK](#3-start-the-sdk)
4. [Analytics APIs](#4-analytics-apis)
5. [Crashes APIs](#5-crashes-apis)
6. [Advanced APIs](#6-advanced-apis)
7. [Troubleshooting](#7-troubleshooting)

Let's get started with setting up the Sonoma iOS SDK in your app to use these services:

## 1. Prerequisites

Before you begin, please make sure that the following prerequisites are met:

* An iOS project that is set up in Xcode on macOS version 10.12.
* The minimum OS target supported by the Sonoma SDK is iOS 8.0 or later

## 2. Integrate the SDK

The Sonoma SDK is designed with a modular approach – a developer only needs to integrate the modules of the services that they're interested in.
You can either integrate the Sonoma SDK by copying it's binaries to your Xcode project (Step 2.1), or by using Cocoapods (Step 2.2).

### 2.1 Integration by copying the binaries into your project

Below are the steps on how to integrate the compiled libraries in your Xcode project to setup the Sonoma SDK for your iOS app.

1. Download the [Sonoma iOS SDK](https://aka.ms/ehvc9e) frameworks provided as a zip file.

2. Unzip the file and you will see different frameworks for each Sonoma service. There is a framework called `SonomaCore`, which is required in the project as it contains the logic for persistence, forwarding etc. 

3. Create a folder in your projects directory in Finder and drag it to Xcode:   
   * Let's create a folder called Vendor (if it doesn't exist) inside your project directory to include all the 3rd-party libraries.  
   * Once created, drag this Vendor folder into Xcode. A dialog will appear. Select "Create groups" and set the checkmark for "Add to targets" for your target. Then click Finish.
   
4. Add the SDK frameworks to the project in Xcode:
    * Make sure the Project Navigator is visible (⌘+1).
    * Now drag and drop `SonomaCore.framework`, `SonomaAnalytics.framework`, and `SonomaCrashes.framework` in the Vendor folder in Xcode using the Project Navigator on the left side. Note that `SonomaCore.framework` is required to start the SDK. So make sure it's added to your project, otherwise the other modules won't work and your app won't compile.
    * A dialog will appear again. Make sure that "Copy items if needed", "Create groups", and your app target are checked. Then click Finish.
    
Now that you've integrated the frameworks in your application, it's time to start the SDK and make use of the Sonoma services.

### 2.2 Integration using Cocoapods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like Sonoma in your projects. To learn how to setup CocoaPods for your project, visit [the official CocoaPods website](http://cocoapods.org/).

1. Add the following to your `podfile` to include all services into your app. This will pull in `SonomaCore`, `SonomaAnalytics` and `SonomaCrashes`. Alternatively, you can specify which features you want to use in your app. Each service has it's own `subspec` and they all rely on `SonomaCore`. It will get pulled in automatically.

```ruby
  # Use the following line to use all features.
  pod 'Sonoma', :podspec => 'https://download.hockeyapp.net/sonoma/ios/Sonoma.podspec'
  
  # Use the following line if you want to specify which service you want to use.
  pod 'Sonoma', :podspec => 'https://download.hockeyapp.net/sonoma/ios/Sonoma.podspec',  :subspecs => ['SonomaAnalytics', 'SonomaCrashes'] 

```

2. Run `pod install` to install your newly defined pod, open your `.xcworkspace` and it's time to start the SDK and make use of the Sonoma services.




## 3. Start the SDK

To start the Sonoma SDK in your app, follow these steps:

1. **Add `import` statements:**  You need to add import statements for Core, Analytics and Crashes module before starting the SDK.
    
    **Objective-C**   
    Open your AppDelegate.m file and add the following lines at the top of the file below your own import statements.   
    
    ```objectivec
    @import SonomaCore;
    @import SonomaAnalytics;
    @import SonomaCrashes;
    ```

    **Swift**   
    Open your AppDelegate.swift file and add the following lines.   
        
    ```swift
    import SonomaCore
    import SonomaAnalytics
    import SonomaCrashes
    ``` 

2. **Start the SDK:** Sonoma provides developers with three modules to get started: SonomaCore (required), Analytics and Crashes. In order to use Sonoma services, you need to opt in for the module(s) that you'd like, meaning by default no modules are started and you will have to explicitly call each of them, both Analytics and Crashes, when starting the SDK.

    **Objective-C**   
    Insert the following line to start the SDK in your app's AppDelegate.m class in the `didFinishLaunchingWithOptions` method.  
    
    ```objectivec
    [SNMSonoma start:@"{Your App Secret}" withFeatures:@[[SNMAnalytics class], [SNMCrashes class]]];
    ```

    **Swift**   
    Insert the following line to start the SDK in your app's AppDelegate.swift class in the `didFinishLaunchingWithOptions` method.   
    
    ```swift
    SNMSonoma.start("{Your App Secret}", withFeatures: [SNMAnalytics.self, SNMCrashes.self])
    ```    
    
    You can also copy paste the `start` method call from the Overview page on Sonoma portal once your app is selected. It already includes the App Secret so that all the data collected by the SDK corresponds to your application. Make sure to replace {Your App Secret} text with the actual value for your application.
    
The example above shows how to use the `start` method and include both the Analytics and Crashes module. If you wish not to use Analytics, remove the parameter from the method call above. Note that, unless you explicitly specify each module as parameters in the start method, you can't use that Sonoma service. Also, the `start` API can be used only once in the lifecycle of your app – all other calls will log a warning to the console and only the modules included in the first call will be available.

## 4. Analytics APIs

* **Track Session, Device Properties:**  Once the Analytics module is included in your app and the SDK is started, it will automatically track sessions, device properties like OS version, model, manufacturer etc. and you don’t need to add any additional code.
    Look at the section above on how to [Start the SDK](#3-start-the-sdk) if you haven't started it yet.

* **Custom Events:** You can track your own custom events with specific properties to know what's happening in your app, understand user actions, and see the aggregates in the Sonoma portal. Once you have started the SDK, use the `trackEvent` method to track your events with properties.

    **Objective-C**
    ```objectivec
    NSDictionary *properties = @{@"Category" : @"Music", @"FileName" : @"favorite.avi"};
    [SNMAnalytics trackEvent:@"Video clicked" withProperties: properties];
    ```

    **Swift**
    ```swift
    SNMAnalytics.trackEvent("Video clicked", withProperties: ["Category" : "Music", "FileName" : "favorite.avi"])
    ```    
    
   Properties for events are entirely optional. If you just want to track an event use this sample instead:

    **Objective-C**
    ```objectivec
    [SNMAnalytics trackEvent:@"Video clicked"];
    ```

    **Swift**
    ```swift
    SNMAnalytics.trackEvent("Video clicked")
    ```

* **Enable or disable Analytics:**  You can change the enabled state of the Analytics module at runtime by calling the `setEnabled` method. If you disable it, the SDK will not collect any more analytics information for the app. To re-enable it, pass `true` as a parameter in the same method.

    **Objective-C**
    ```objectivec
    [SNMAnalytics setEnabled:NO];
    ```

    **Swift**
    ```swift
    SNMAnalytics.setEnabled(false)
    ```

    You can also check if the module is enabled or not using the `isEnabled` method:

    **Objective-C**
    ```objectivec
    BOOL enabled = [SNMAnalytics isEnabled];
    ```

    **Swift**
    ```swift
    var enabled = SNMAnalytics.isEnabled()
    ```
    
## 5. Crashes APIs

Once you set up and start the Sonoma SDK to use the Crashes module in your application, the SDK will automatically start logging any crashes in the devices local storage. When the user opens the application again after a crash, all pending crash logs will automatically be forwarded to Sonoma and you can analyze the crash along with the stack trace on the Sonoma portal. Refer to the section to [Start the SDK](#3-start-the-sdk) if you haven't done so already.

* **Generate a test crash:** The SDK provides you with a static API to generate a test crash for easy testing of the SDK:

    **Objective-C**
    ```objectivec
    [SNMCrashes generateTestCrash];
    ```

    **Swift**
    ```swift
    SNMCrashes.generateTestCrash()
    ```

    Note that this API will only work for development and test apps. The method will not be functioning once the app is distributed through the App Store.

* **Did the app crash in the last session:** At any time after starting the SDK, you can check if the app crashed in the previous session:

    **Objective-C**
    ```objectivec
    [SNMCrashes hasCrashedInLastSession];
    ```

    **Swift**
    ```swift
    SNMCrashes.hasCrashedInLastSession()
    ```

* **Details about the last crash:** If your app crashed previously, you can get details about the last crash:

    **Objective-C**
    ```objectivec
    SNMErrorReport *crashReport = [SNMCrashes lastSessionCrashReport];
    ```

    **Swift**
    ```swift
    var crashReport = SNMCrashes.lastSessionCrashReport()
    ```

* **Enable or disable the Crashes module:**  You can disable and opt out of using the Crashes module by calling the `setEnabled` API and the SDK will collect no more crashes for your app. Use the same API to re-enable it by passing `YES` or `true` as a parameter.

    **Objective-C**
    ```objectivec
    [SNMCrashes setEnabled:NO];
    ```

    **Swift**
    ```swift
    SNMCrashes.setEnabled(false)
    ```
    
    You can also check if the module is enabled or not using the `isEnabled` method:

    **Objective-C**
    ```objectivec
    BOOL enabled = [SNMCrashes isEnabled];
    ```

    **Swift**
    ```swift
    var enabled = SNMCrashes.isEnabled()
    ```


* **Advanced Scenarios:**  The Crashes module provides delegates for developers to perform additional actions before and when sending crash reports to Sonoma. This gives you added flexibility on the crash reports that will be sent.

        **Objective-C**
        ```objectivec
        [SNMCrashes setDelegate:self];
        ```

        **Swift**
        ```swift
        [SNMCrashes setDelegate:self];
        ```

    The following delegates are provided:
    
    * **Should the crash be processed:** Implement this delegates if you'd like to decide if a particular crash needs to be processed or not. For example - there could be some system level crashes that you'd want to ignore and don't want to send to Sonoma.

          **Objective-C**
          ```objectivec
          - (BOOL)crashes:(SNMCrashes *)crashes shouldProcessErrorReport:(SNMErrorReport *)errorReport {
              return YES; // return YES if the crash report should be processed, otherwise NO.
          }
          ```

          **Swift**
          ```swift
          (BOOL)crashes:(SNMCrashes *)crashes shouldProcessErrorReport:(SNMErrorReport *)errorReport {
              return true; // return true if the crash report should be processed, otherwise false.
          }
          ```
        
    * **User Confirmation:** If user privacy is important to you as a developer, you might want to get user confirmation before sending a crash report to Sonoma. The SDK exposes a callback where you can tell it to await user confirmation before sending any crash reports.
    Your app is then responsible for obtaining confirmation, e.g. through a dialog prompt with one of these options - "Always Send", "Send", and "Don't send". Based on the user input, you will tell the SDK and the crash will then respectively be forwarded to Sonoma or not.


        **Objective-C**
        ```objectivec
         [SNMCrashes setUserConfirmationHandler:(^(NSArray<SNMErrorReport *> *errorReports) {
            return YES; // Return YES if the SDK should await user confirmation, otherwise NO.
        }
        ```

        **Swift**
        ```swift
        [SNMCrashes setUserConfirmationHandler:(^(NSArray<SNMErrorReport *> *errorReports) {
            return true; // Return true if the SDK should await user confirmation, otherwise false.
        }
        ```
        
        If you return `true`, your app should obtain user permission and message the SDK with the result using the following API:

        **Objective-C**
        ```objectivec
        [SNMCrashes notifyWithUserConfirmation:SNMUserConfirmation];
        ```

        **Swift**
        ```swift
        [SNMCrashes notifyWithUserConfirmation:SNMUserConfirmation];
        ```

        Pass one option of `SNMUserConfirmationDontSend`, `SNMUserConfirmationAlways` or `SNMUserConfirmationSend`.

    * **Binary attachment:**  If you'd like to attach text/binary data to a crash report, implement this callback. Before sending the crash, our SDK will add the attachment to the crash report and you can view it on the Sonoma portal.   

        **Objective-C**
        ```objectivec
        - (SNMErrorAttachment *)attachmentWithCrashes:(SNMCrashes *)crashes forErrorReport:(SNMErrorReport *)errorReport {
            // return your own created ErrorAttachment object
        }
        ```

        **Swift**
        ```swift
        - (SNMErrorAttachment *)attachmentWithCrashes:(SNMCrashes *)crashes forErrorReport:(SNMErrorReport *)errorReport {
            // return your own created ErrorAttachment object
        }
        ```

    * **Before sending a crash report:** This callback will be invoked just before the crash is sent to Sonoma:

        **Objective-C**
        ```objectivec
        - (void)crashes:(SNMCrashes *)crashes willSendErrorReport:(SNMErrorReport *)errorReport {
            …
        }
        ```

        **Swift**
        ```swift
        - (void)crashes:(SNMCrashes *)crashes willSendErrorReport:(SNMErrorReport *)errorReport {
            …
        }
        ```

    * **When sending a crash report succeeded:** This callback will be invoked after sending a crash report succeeded:

        **Objective-C**
        ```objectivec
        - (void)crashes:(SNMCrashes *)crashes didSucceedSendingErrorReport:(SNMErrorReport *)errorReport {
            …
        }
        ```

        **Swift**
        ```swift
        - (void)crashes:(SNMCrashes *)crashes didSucceedSendingErrorReport:(SNMErrorReport *)errorReport {
            …
        }
        ```

    * **When sending a crash report failed:** This callback will be invoked after sending a crash report failed:

        **Objective-C**
        ```objectivec
        - (void)crashes:(SNMCrashes *)crashes didFailSendingErrorReport:(SNMErrorReport *)errorReport withError:(NSError *)error {
            …
        }
        ```

        **Swift**
        ```swift
        - (void)crashes:(SNMCrashes *)crashes didFailSendingErrorReport:(SNMErrorReport *)errorReport withError:(NSError *)error {
            …
        }
        ```

## 6. Advanced APIs

* **Debugging**: You can control the amount of log messages that show up from the Sonoma SDK. Use the `setLogLevel` API to enable additional logging while debugging. By default, it is set to `SNMLogLevelAssert` for App Store environment, `SNMLogLevelWarning` otherwise.

    **Objective-C**
    ```objectivec
    [SNMSonoma setLogLevel:SNMLogLevelVerbose];
    ```

    **Swift**
    ```swift
    SNMSonoma.setLogLevel(SNMLogLevel.Verbose)
    ```

* **Get Install Identifier**: The Sonoma SDK creates a UUID for each device once the app is installed. This identifier remains the same for a device when the app is updated and a new one is generated only when the app is re-installed. The following API is useful for debugging purposes:

    **Objective-C**
    ```objectivec
    NSUUID *installId = [SNMSonoma installId];
    ```

    **Swift**
    ```swift
    var installId = SNMSonoma.installId()
    ```

* **Enable/Disable the Sonoma SDK:** If you want the Sonoma SDK to be disabled completely, use the `setEnabled` API. When disabled, the SDK will not forward any information to Sonoma.

    **Objective-C**
    ```objectivec
    [SNMSonoma setEnabled:NO];
    ```

    **Swift**
    ```swift
    SNMSonoma.setEnabled(false)
    ```
        
## 7. Troubleshooting

* How long to wait for Analytics data to appear on the portal?  

* How long to wait for crashes to appear on the portal?   
  After restarting the app after the crash and with a working internet connection, the crash should appear on the portal within a few minutes. Note that the matching dSYM needs to be uploaded as well.

* Do I need to include all the libraries? 
  No, you can just include Sonoma modules that interests you but the core module which contains logic for persistence, forwarding etc. is mandatory.

* Can't see crashes on the portal?   
   * Make sure SDK `start()` API is used correctly and Crashes module is initialized. Also, you need to restart the app after a crash and our SDK will forward the crash log only after it's restarted.
   * The user needs to upload the symbols that match the UUID of the build that triggered the crash.
   * Make sure your device is connected to a working internet.
   * Check if the App Secret used to start the SDK matches the App Secret in Sonoma portal.
   * Don't use any other SDK that provides Crash Reporting functionality.

* What data does SDK automatically collect for Analytics?

* What permissions are required for the SDK?   
  Sonoma iOS SDK requires no permissions to be set in your app.

* Any privacy information tracked by SDK?



