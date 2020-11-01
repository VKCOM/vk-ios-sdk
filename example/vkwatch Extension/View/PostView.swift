//
//  PostView.swift
//  vkwatch Extension
//
//  Created by Дмитрий Червяков on 30.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostView: View {
    var post: PostModel

    var body: some View {
        VStack {
            HStack {
                WebImage(url: URL(string: "https://sun9-51.userapi.com/impg/nBobjyazLVWoGB77Mgh1vugjxLwPFUExD8mLSA/VfrUQyRzJ-Q.jpg?size=100x0&quality=88&crop=1044,484,541,541&sign=235c184b1cecdb0963a18a6831178d2b&ava=1"))
                    .onSuccess { image, data, cacheType in
                        // Success
                        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                    }
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
                    .scaledToFit()
                    .frame(width: 30, height: 30, alignment: .center)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                VStack(alignment: .leading) {
                    Text(post.postAuhtor)
                        .font(.system(size: 13))
                    Text(post.forrmatedDate)
                        .font(.system(size: 13))
                }
            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            PostView(post: PostModel(id: 0, postAuhtor: "Nikita puzankov", forrmatedDate: "28 Oct at 20:30"))
            PostView(post: PostModel(id: 0, postAuhtor: "Nikita puzankov", forrmatedDate: "28 Oct at 20:30"))
        }
        .previewLayout(.fixed(width: 200, height: 70))
    }
}
