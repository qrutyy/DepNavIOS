//
//  SVGCache.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import Foundation
import SVGView

final class SVGCache {
    
    static let shared = SVGCache()
    
    // key - URL (like NSURL), value - parsed file (SVGNode).
    private let cache = NSCache<NSURL, SVGNode>()
    
    private init() { } // private init for singleton
    
    func getNode(for url: URL) -> SVGNode? {
        let key = url as NSURL
        
        // check if the key is in the cache
        if let cachedNode = cache.object(forKey: key) {
            // print("SVGCache: Returning cached node for \(url.lastPathComponent)")
            return cachedNode
        }
        
        // if key wasn't found in cache - parse the image
        print("SVGCache: Parsing and caching new node for \(url.lastPathComponent)")
        guard let newNode = SVGParser.parse(contentsOf: url) else {
            return nil // Парсинг не удался
        }
        
        // save the parsed file node into the cache
        cache.setObject(newNode, forKey: key)
        
        return newNode
    }
}
