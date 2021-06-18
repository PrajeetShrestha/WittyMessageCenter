//
//  MessageCenter.swift
//  PSArsenal
//
//  Created by Prajeet Shrestha on 01/06/2021.
//

import Foundation
///
///A class to simplify usage of NSNotificationCenter
///
/// **Example:**
///
/// **1. Initialize**
///
///     let messageCenter = MessageCenter()
///
/// **2.0 Send Notification**
///
///     //2.1. Send Notification without data
///     messageCenter.send(name: .homePageFetchComplete)
///
///     //2.2 Send Notification with data
///     messageCenter.send(name: .homePageFetchComplete, ["name": "Prajeet"])
///
/// **3.0 Observe Notification**
///
///     //3.1 Observe without data
///     messageCenter.observe(name: .homePageFetchComplete) {[weak self] _ in
///         self?.lblMessage.text = "Got Notification"
///     }
///
///     //3.2 Observe with data
///     messageCenter.observe(name: .homePageFetchComplete) {[weak self] data in
///     self?.lblMessage.text = "Got Notification"
///
/// **Notes**
///
/// 1. Can cause cyclic reference.
/// 2. There will be a retention cycle, if callback methods capture strong references and you don't call remove() method.
/// 3. You can use weak reference in callback closures to prevent retention cycle.
/// 4. If you use weak references then you don't need to call remove() method explicitly.

public class MessageCenter {
    private static let notificationCenter = NotificationCenter()
    public var scope:String = ""
    public typealias CallBack = (_ data:[AnyHashable:Any]?) -> Void
    
    public init() {}
    
    private var callbackStore = [String : CallBack]()
    
    /// Observe Notification in NSNotificationCenter.default
    /// - Parameters:
    ///   - name: Name of a notification as string
    ///   - callback: Closure to be executed upon receiving notificaitons
    ///
    ///callback will also return a userinfo as data from dictionary
    
    public func observe(name:String, callback:@escaping CallBack) {
        
        MessageCenter.notificationCenter.addObserver (self,
                                                      selector: #selector(self.notificationCallback),
                                                      name: NSNotification.Name(name),
                                                      object: nil)
        callbackStore[name] = callback
    }
    
    
    /// Sends notification through NSNotificationCenter.default
    /// - Parameters:
    ///   - name: Name of notification as string
    ///   - data: Data to be passed as user info in Notification Object
    public func send(name:String, data:[String:AnyObject]? = nil) {
        MessageCenter.notificationCenter.post(name: NSNotification.Name(name),
                                              object: nil, userInfo:data)
    }
    
    /// Method to remove notification observer
    public func remove() {
        callbackStore.removeAll()
        MessageCenter.notificationCenter.removeObserver(self)
    }
    
    @objc private func notificationCallback(notification: Notification) {
        if let callback = callbackStore[notification.name.rawValue] {
            callback(notification.userInfo)
        }
    }
    
    deinit {
        //print("MessageCenter deinit from: \(scope)")
        remove()
    }
}

public protocol Notifiable {
    var messageCenter:MessageCenter { get }
    func observeNotifications()
}
