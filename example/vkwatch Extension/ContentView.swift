//
//  ContentView.swift
//  vkwatch Extension
//
//  Created by Дмитрий Червяков on 27.10.2020.
//  Copyright © 2020 VK. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Gauge(value: /*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/, in: /*@START_MENU_TOKEN@*/0...1/*@END_MENU_TOKEN@*/) {
                Text("Label")
                Text("asdas")
            }
            CircleImage()
                .offset(y: -13)
                .padding(.bottom, -13)
                .edgesIgnoringSafeArea(.top)
            VStack(alignment: .leading) {
                Text("Tortle Rock")
                    .font(.title)
                HStack {
                    Text("National park")
                        .font(.subheadline)
                    Spacer()
                    Text("California")
                        .font(.subheadline)
                }
            }
            .padding(4)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
