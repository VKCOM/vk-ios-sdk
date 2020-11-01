//
//  VKSDKTestApplicationApp.swift
//  vkwatch Extension
//
//  Created by Дмитрий Червяков on 27.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

import SwiftUI

@main
struct VKSDKTestApplicationApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
