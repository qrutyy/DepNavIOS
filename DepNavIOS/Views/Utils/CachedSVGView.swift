//
//  CachedSVGView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import SVGView
import SwiftUI

// Simple cached modification of the default SVGView.

public struct CachedSVGView: View {
    public let svg: SVGNode?

    public init(contentsOf url: URL) {
        // Old: self.svg = SVGParser.parse(contentsOf: url)
        svg = SVGCache.shared.getNode(for: url)
    }

    @available(*, deprecated, message: "Use (contentsOf:) initializer instead")
    public init(fileURL: URL) {
        // old: self.svg = SVGParser.parse(contentsOf: fileURL)
        svg = SVGCache.shared.getNode(for: fileURL)
    }

    // other initializers remain the same, for kiss (fyi we don't use them)
    public init(data: Data) {
        svg = SVGParser.parse(data: data)
    }

    public init(string: String) {
        svg = SVGParser.parse(string: string)
    }

    public init(stream: InputStream) {
        svg = SVGParser.parse(stream: stream)
    }

    public init(xml: XMLElement) {
        svg = SVGParser.parse(xml: xml)
    }

    public init(svg: SVGNode) {
        self.svg = svg
    }

    public func getNode(byId id: String) -> SVGNode? {
        return svg?.getNode(byId: id)
    }

    public var body: some View {
        svg?.toSwiftUI()
    }
}
