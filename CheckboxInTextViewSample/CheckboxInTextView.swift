//
//  CheckboxInTextView.swift
//  CheckboxInTextViewSample
//
//  Created by Shuhei Yukawa on 2020/01/15.
//  Copyright © 2020 Shuhei Yukawa. All rights reserved.
//

import Foundation
import UIKit

// https://qiita.com/marty-suzuki/items/496f211e22cad1f8de19
extension DispatchQueue {
    func throttle(delay: DispatchTimeInterval) -> (_ action: @escaping () -> ()) -> () {
        var lastFireTime: DispatchTime = .now()

        return { [weak self, delay] action in
            let deadline: DispatchTime = .now() + delay
            self?.asyncAfter(deadline: deadline) { [delay] in
                let now: DispatchTime = .now()
                let when: DispatchTime = lastFireTime + delay
                if now < when { return }
                lastFireTime = .now()
                action()
            }
        }
    }
}

class CheckboxInTextView: UITextView {
    static private let checkBoxSize: CGSize = CGSize(width: 30, height: 30)

    private let throttle = DispatchQueue.main.throttle(delay: .milliseconds(200))
    private var _font: UIFont = UIFont.preferredFont(forTextStyle: .body)
    override var text: String! {
        set {
            super.text = newValue
        }
        get {
            return self.getDecodedText()
        }
    }
    
    override var font: UIFont? {
        set {
            super.font = newValue
            guard let font = newValue else { return }
            self._font = font
            
        }
        get {
            return super.font
        }
    }
    
    override func insertText(_ text: String) {
        super.insertText(text)
        self.updateText()
    }
    
    private func updateText() {
        let matchesForUncheck = self.mathces(pattern: "- \\[\\]")
        matchesForUncheck.forEach { (match) in
            self.setTextAttachement(range: match.range, checked: false)
        }
        
        let matchesForCheck = self.mathces(pattern: "- \\[x\\]")
        matchesForCheck.forEach { (match) in
            self.setTextAttachement(range: match.range, checked: true)
        }
        // NSTextAttachment を追加したあと、元のフォント情報が失われてしまうので再度セットする
        self.setOriginalFontAttribute()
    }
    
    private func mathces(pattern: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let matches = regex.matches(in: self.attributedText.string, range: NSRange(location: 0, length: self.attributedText.string.count))
        return matches
    }
    
    private func setOriginalFontAttribute() {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
        let textAttributes: [NSAttributedString.Key: Any] = [ .font: self._font ]
        attributeString.addAttributes(textAttributes, range: NSRange(location: 0, length: self.attributedText.string.count))
        self.attributedText = attributeString
    }
    
    private func setTextAttachement(range: NSRange, checked: Bool) {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
        let textAttachement = CheckboxTextAttachement(data: nil, ofType: nil)
        textAttachement.setChecked(checked: checked)
        
        textAttachement.bounds = CGRect(x: 5, y: self.getPositionYForTextAttachment(),
                                        width: CheckboxInTextView.checkBoxSize.width,
                                        height: CheckboxInTextView.checkBoxSize.height)
        let newAttributeString = NSAttributedString(attachment: textAttachement)
        
        attributeString.replaceCharacters(in: range, with: newAttributeString)
        
        self.attributedText = attributeString
    }
    
    // チェックボックス以降の入力がチェックボックスの中心にくるよう調整(TODO: アクセシビリティ対応になっていない)
    private func getPositionYForTextAttachment() -> CGFloat {
        let lineHeight = UIFontMetrics(forTextStyle: .body).scaledFont(for: _font).capHeight
        return ((CheckboxInTextView.checkBoxSize.height - lineHeight) / 2) * -1
    }
    
    private func getDecodedText() -> String {
        let newAttributeText = NSMutableAttributedString(attributedString: self.attributedText)
        newAttributeText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.attributedText.length)) { (attribute, range, finish) in
            guard let checkbox = attribute as? CheckboxTextAttachement else {
                return
            }
            if checkbox.checked {
                newAttributeText.replaceCharacters(in: range, with: NSAttributedString(string: "- [x]"))
            } else {
                newAttributeText.replaceCharacters(in: range, with: NSAttributedString(string: "- []"))
            }
        }
        return newAttributeText.string
    }
}

extension CheckboxInTextView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let glyphIndex: Int = self.layoutManager.glyphIndex(for: point, in: self.textContainer, fractionOfDistanceThroughGlyph: nil)
        
        let glyphRect = self.layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: self.textContainer)
        guard glyphRect.contains(point) else { return self }
        let characterIndex: Int = self.layoutManager.characterIndexForGlyph(at: glyphIndex)
        guard characterIndex < self.textStorage.length,
            NSTextAttachment.character == (self.textStorage.string as NSString).character(at: characterIndex),
            let attachment = self.textStorage.attribute(.attachment, at: characterIndex, effectiveRange: nil) as? CheckboxTextAttachement else {
            return self
        }
        // 入れ替え(二度 hitTest が入ってくるので指定秒内の最後の処理を使用する)
        self.throttle {
            self.attributedText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.attributedText.length)) { (attribute, range, finish) in
                guard let checkbox = attribute as? CheckboxTextAttachement else {
                    return
                }
                
                // 一致したら変更
                if checkbox == attachment {
                    self.setTextAttachement(range: range, checked: !attachment.checked)
                    finish.pointee = true
                }
            }
        }
        return self
    }
}
