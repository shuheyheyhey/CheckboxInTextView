//
//  ViewController.swift
//  CheckboxInTextViewSample
//
//  Created by Shuhei Yukawa on 2020/01/15.
//  Copyright © 2020 Shuhei Yukawa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let textView: CheckboxInTextView = CheckboxInTextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.textView.delegate = self
        self.view.addSubview(self.textView)
        self.textView.font = UIFont.preferredFont(forTextStyle: .body)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        
        self.textView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor).isActive = true
        self.textView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor).isActive = true
        self.textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        //self.textView.updateText()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}
