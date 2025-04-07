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
    var showClearButton: Bool = false
    var onClear: () -> Void = {}
    
    // State for keyboard offset
    @State private var keyboardOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // A clear background that covers the whole area and dismisses the keyboard when tapped.
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isInputFocused = false
                    }
                
                VStack {
                    // Zstack for "clear text" CTA
                    ZStack(alignment: .trailing) {
                        // HStack containing the multi-line TextField + CTA button
                        HStack {
                            TextField("Describe your meal", text: $text, axis: .vertical)
                                .lineLimit(...5) // up to 5 lines
                                .focused($isInputFocused)
                                .padding(.horizontal, 20)
                                .frame(minHeight: 40)
                            //.frame(width: geometry.size.width * 0.8, alignment: .leading)
                            // CTA button on the right
                            Button(action: {
                                onSubmit()
                                // Optionally dismiss the keyboard on submit
                                isInputFocused = false
                            }) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.yellow)
                                        .frame(width: 36, height: 36)
                                    Image("whiskicon")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(.black)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .padding(.trailing, 8)
                        }
                        // Overlay: Clear button appears at the trailing edge if showClearButton is true.
                        if showClearButton && !text.isEmpty {
                            Button(action: {
                                onClear()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.brandGray)
                                    .background(Color.white.opacity(0.001)) // ensures tap area if needed
                            }
                            .padding(.trailing, 50)
                        }
                    }
                    // Text Box styling
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color(red: 242/255, green: 242/255, blue: 242/255), lineWidth: 0.25)
                    )
                    .shadow(color: Color(red: 1.0, green: 192/255, blue: 0).opacity(0.7), radius: 38, x: 0, y: 0)
                    .padding(.horizontal)
                    
                    //Spacer()
                }
                //Horizontal Padding for the overall text box
                .padding(.horizontal)
                // This padding moves the entire view up when keyboard appears
                .padding(.bottom, keyboardOffset)
                .animation(.easeInOut(duration: 0.3), value: keyboardOffset)
                // Listen for keyboard show/hide notifications
                .onAppear {
                    setupKeyboardObservers()
                }
                .onDisappear {
                    removeKeyboardObservers()
                }
            }
        }
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                               object: nil,
                                               queue: .main) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardOffset = frame.height
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { _ in
            keyboardOffset = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// PREVIEW FUNCTION
struct ExpandableInputView_Previews: PreviewProvider {
    @State static var sampleText = "test test mic to see how the wrapping works on this lorem ipsum field text text test"
    
    static var previews: some View {
        ExpandableInputView(text: $sampleText, onSubmit: {
            print("Submitted: \(sampleText)")
        })
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
