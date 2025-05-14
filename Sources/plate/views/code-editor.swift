import SwiftUI

#if os(iOS)
import UIKit

public struct CodeEditor: UIViewRepresentable {
    @Binding public var text: String
    public var font: UIFont
    public var textColor: UIColor
    public var backgroundColor: UIColor

    public init(
        text: Binding<String>,
        font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular),
        textColor: UIColor = .label,
        backgroundColor: UIColor = .systemBackground
    ) {
        self._text = text
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }

    public func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.font = font
        tv.textColor = textColor
        tv.backgroundColor = backgroundColor

        // Enable horizontal scrolling & disable wrapping:
        tv.isScrollEnabled = true
        tv.alwaysBounceHorizontal = true
        tv.showsHorizontalScrollIndicator = true
        tv.textContainer.lineBreakMode = .byClipping
        tv.textContainer.widthTracksTextView = false

        // Optional tweaks for code editing:
        tv.autocapitalizationType    = .none
        tv.autocorrectionType        = .no
        tv.spellCheckingType         = .no
        tv.keyboardType              = .default

        return tv
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: CodeEditor
        init(_ parent: CodeEditor) { self.parent = parent }

        public func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

#elseif os(macOS)
import AppKit

public struct CodeEditor: NSViewRepresentable {
    @Binding public var text: String
    public var font: NSFont
    public var textColor: NSColor
    public var backgroundColor: NSColor

    public init(
        text: Binding<String>,
        font: NSFont = .monospacedSystemFont(ofSize: 14, weight: .regular),
        textColor: NSColor = .labelColor,
        backgroundColor: NSColor = .windowBackgroundColor
    ) {
        self._text = text
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }

    public func makeNSView(context: Context) -> NSScrollView {
        let tv = NSTextView(frame: .zero)
        tv.delegate       = context.coordinator
        tv.isRichText     = false
        tv.font           = font
        tv.textColor      = textColor
        tv.backgroundColor = backgroundColor

        tv.isHorizontallyResizable = true
        tv.isVerticallyResizable   = true
        tv.textContainer?.widthTracksTextView  = false
        tv.textContainer?.heightTracksTextView = false
        tv.textContainer?.containerSize = NSSize(
            width:  CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        tv.minSize = NSSize(width: 0, height: 0)
        tv.maxSize = NSSize(
            width:  CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        tv.autoresizingMask = []

        let scroll = NSScrollView(frame: .zero)
        scroll.documentView           = tv
        scroll.hasVerticalScroller    = true
        scroll.hasHorizontalScroller  = true
        scroll.horizontalScrollElasticity = .allowed
        scroll.verticalScrollElasticity   = .allowed
        scroll.autohidesScrollers     = false
        scroll.drawsBackground        = false
        scroll.wantsLayer = true
        scroll.layer?.cornerRadius = 8
        scroll.layer?.masksToBounds = true

        return scroll
    }

    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        if
            let tv = nsView.documentView as? NSTextView,
            tv.string != text
        {
            tv.string = text
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CodeEditor
        init(_ parent: CodeEditor) { self.parent = parent }

        public func textDidChange(_ notification: Notification) {
            guard
                let tv = notification.object as? NSTextView
            else { return }
            parent.text = tv.string
        }
    }
}

#endif
