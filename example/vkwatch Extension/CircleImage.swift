//
//  CircleImage.swift
//  vkwatch Extension
//
//  Created by Дмитрий Червяков on 28.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    var body: some View {
        VStack {
            Image("turtlerock")
                .frame(width: 130, height: 130, alignment: .bottom)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(color: .white, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: 0.0, y: 5.0)
        }
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage()
    }
}
