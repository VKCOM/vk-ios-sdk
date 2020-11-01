//
//  VKSDKTestApplicationApp.swift
//  vkwatch Extension
//
//  Created by Дмитрий Червяков on 27.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

import SwiftUI
import WatchConnectivity
//import SwiftyVK

@main
struct VKSDKTestApplicationApp: App {

    private var connectovityManager = PhoneConnectivityManager()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    PostView(post: PostModel(id: 0, postAuhtor: "Nikita puzankov", forrmatedDate: "28 Oct at 20:30"))
                    Button(action: {
                        connectovityManager.sendMessage()
                    }) {
                        Text("send")
                    }
                }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

struct VKSDKTestApplicationApp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Text("Hello, World!")
        }
    }
}
