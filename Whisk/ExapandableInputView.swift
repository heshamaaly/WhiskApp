//
//  ExapandableInputView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/28/25.
//
import SwiftUI

struct ExpandableInputView: View {
    @Binding var text: String
    @FocusState private var isInputFocused: Bool
    let onSubmit: () -> Void

    var body: some View {
        
        GeometryReader { geometry in
            HStack {
                // Single-line TextField
                TextField("Describe your meal", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isInputFocused)
                // Some horizontal padding inside the field
                    .padding(.horizontal, 20)
                // Minimum height for a comfortable tap target
                    .frame(width: geometry.size.width * 0.8)
                    .frame(minHeight: 40)
                
                // CTA button on the right
                Button(action: onSubmit) {
                    ZStack {
                        Circle()
                            .foregroundColor(.yellow)
                            .frame(width: 36, height: 36)
                        Image("whiskicon") // <-- Use the asset name you added
                            .resizable()
                        // If you want to tint the icon black:
                            .renderingMode(.template)
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.trailing, 8)
            }
            // Text Box styling
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.75)) // White background at 75% opacity (i.e. 25% transparent)
            //.background(.ultraThinMaterial)  // Using a built-in blur for that glassmorphism feel
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color(red: 242/255, green: 242/255, blue: 242/255), lineWidth: 0.25)
            )
            .shadow(color: Color(red: 1.0, green: 192/255, blue: 0).opacity(0.7), radius: 38, x: 0, y: 0)
            .padding(.horizontal)
        }
    }
}

//Preview

struct ExpandableInputView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableInputView(
            text: .constant("Sample text"),
            onSubmit: {
                // Add whatever test action you like, e.g.:
                print("Preview Submit Tapped!")
            }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
