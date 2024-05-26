//
//  TextView.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return TextView.Coordinator(parent: self)
    }
    
    
    @Binding var text: String
    @Binding var height: CGFloat
    var fontSize: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.backgroundColor = .clear
        view.font = .systemFont(ofSize: fontSize)
        view.text = text
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        
    }
    class Coordinator: NSObject, UITextViewDelegate{
        var parent: TextView
        
        init(parent: TextView){
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            let height = textView.contentSize.height
            
            self.parent.height = height
            
            self.parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            let height = textView.contentSize.height
            
            self.parent.height = height
        }
    }
}

