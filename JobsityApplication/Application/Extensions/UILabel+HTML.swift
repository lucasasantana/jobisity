//
//  UILabel+HTML.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

extension UILabel {
    func setHTMLFromString(htmlText: String?) {
        guard let font = self.font, let content = htmlText else {
            self.text = htmlText
            self.attributedText = nil
            return
        }
        
        let modifiedFont = String(
            format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(font.pointSize)\">%@</span>",
            content
        )
        
        let attrStr = try? NSAttributedString(
            data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding:String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
        
        self.text = nil
        self.attributedText = attrStr
    }
}
