//
//  LogoHeaderView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/31/25.
//

import SwiftUI

struct LogoHeaderView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 20)
            Image("WhiskLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            Spacer().frame(height: 10)
        }
    }
}
