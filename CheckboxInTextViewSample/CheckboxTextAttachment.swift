//
//  CheckboxTextAttachment.swift
//  CheckboxInTextViewSample
//
//  Created by Shuhei Yukawa on 2020/01/16.
//  Copyright © 2020 Shuhei Yukawa. All rights reserved.
//

import Foundation
import UIKit

class CheckboxTextAttachement: NSTextAttachment {
    var checked: Bool = false
    
    override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setChecked(checked: Bool) {
        self.checked = checked
        
        if self.checked {
            self.image = #imageLiteral(resourceName: "checked")
        } else {
            self.image = #imageLiteral(resourceName: "unchecked")
        }
    }
}
