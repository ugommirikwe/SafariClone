//
//  String+Extension.swift
//  SafariClone
//
//  Created by Ugochukwu Mmirikwe on 2022/02/03.
//

import Foundation

extension String {
    func parseAsURL() -> URL? {
        var _urlString = self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if _urlString.isEmpty {
            return nil
        }
        
        if _urlString.prefix(8) != "https://" && _urlString.prefix(7) != "http://" {
            _urlString = "https://\(_urlString)"
        }
        
        var url: URL?
        
        if let urlFromURLComponents = URLComponents(string: _urlString)?.url,
           urlFromURLComponents.host != nil {
            url = urlFromURLComponents
        }
        
        return url
    }
}
