import SwiftUI

public struct CodeEditorContainer: View {
    @State public var text: Binding<String>
    @State public var wrap = false

    public init(
        text: Binding<String>,
        wrap: Bool = false
    ) {
        self.text = text
        self.wrap = wrap
    }

    public var body: some View {
        VStack {
            HStack {
                // Spacer()
                StandardToggle(style: .switch, isOn: $wrap, title: "Wrap Lines (Beta)")
            }
            .padding()

            CodeEditor(
                text: text,
                wrapLines: wrap
            )
            // .frame(maxWidth: .infinity, maxHeight: .infinity)
            // .frame(minHeight: 200)
        }
    }
}

#if os(iOS)
import UIKit

public struct CodeEditor: UIViewRepresentable {
    @Binding public var text: String
    public var font: UIFont
    public var textColor: UIColor
    public var backgroundColor: UIColor
    public var wrapLines: Bool

    public init(
        text: Binding<String>,
        font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular),
        textColor: UIColor = .label,
        backgroundColor: UIColor = .systemBackground,
        wrapLines: Bool = false
    ) {
        self._text = text
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.wrapLines = wrapLines
    }

    public func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.font = font
        tv.textColor = textColor
        tv.backgroundColor = backgroundColor

        // Enable horizontal scrolling & disable wrapping:
        // tv.isScrollEnabled = true
        // tv.alwaysBounceHorizontal = true
        // tv.showsHorizontalScrollIndicator = true
        // tv.textContainer.lineBreakMode = .byClipping
        // tv.textContainer.widthTracksTextView = false

        tv.isScrollEnabled = true
        tv.alwaysBounceHorizontal = !wrapLines
        tv.showsHorizontalScrollIndicator = !wrapLines
        tv.textContainer.lineBreakMode = wrapLines ? .byWordWrapping : .byClipping
        tv.textContainer.widthTracksTextView = wrapLines

        // setting containerwidth
        let insets = tv.textContainerInset
        let containerWidth = wrapLines
        ? tv.bounds.width - insets.left - insets.right : CGFloat.greatestFiniteMagnitude
        tv.textContainer.containerSize = CGSize(
            width:  containerWidth,
            height: CGFloat.greatestFiniteMagnitude
        )


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

        uiView.textContainer.lineBreakMode       = wrapLines ? .byWordWrapping : .byClipping
        uiView.textContainer.widthTracksTextView = wrapLines

        let insets = uiView.textContainerInset
        let width = wrapLines ? uiView.bounds.width - insets.left - insets.right : CGFloat.greatestFiniteMagnitude

        uiView.textContainer.containerSize = CGSize(
            width:  width,
            height: CGFloat.greatestFiniteMagnitude
        )

        uiView.alwaysBounceHorizontal   = !wrapLines
        uiView.showsHorizontalScrollIndicator = !wrapLines
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
    public var wrapLines: Bool

    public init(
        text: Binding<String>,
        font: NSFont = .monospacedSystemFont(ofSize: 14, weight: .regular),
        textColor: NSColor = .labelColor,
        backgroundColor: NSColor = .windowBackgroundColor,
        wrapLines: Bool = false
    ) {
        self._text = text
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.wrapLines = wrapLines
    }

    public func makeNSView(context: Context) -> NSScrollView {
        let tv = NSTextView(frame: .zero)
        tv.delegate       = context.coordinator
        tv.isRichText     = false
        tv.font           = font
        tv.textColor      = textColor
        tv.backgroundColor = backgroundColor

        // tv.isHorizontallyResizable = true
        // tv.isVerticallyResizable   = true
        // tv.textContainer?.widthTracksTextView  = false
        // tv.textContainer?.heightTracksTextView = false
        // tv.textContainer?.containerSize = NSSize(
        //     width:  CGFloat.greatestFiniteMagnitude,
        //     height: CGFloat.greatestFiniteMagnitude
        // )

        // wrap toggling
        tv.isHorizontallyResizable   = !wrapLines
        tv.isVerticallyResizable     = true
        tv.textContainer?.widthTracksTextView  = wrapLines
        // tv.textContainer?.heightTracksTextView = true
        tv.textContainer?.heightTracksTextView = false
        if !wrapLines {
            // allow infinite width so horizontal scrolling works
            tv.textContainer?.containerSize = NSSize(
                width:  CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
        }

        // unchanged
        tv.minSize = NSSize(width: 0, height: 0)
        tv.maxSize = NSSize(
            width:  CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        tv.autoresizingMask = []

        let scroll = NSScrollView(frame: .zero)
        scroll.documentView           = tv
        scroll.hasVerticalScroller    = true
        // scroll.hasHorizontalScroller  = true
        scroll.hasHorizontalScroller  = !wrapLines
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
        // if
        //     let tv = nsView.documentView as? NSTextView,
        //     tv.string != text
        // {
        //     tv.string = text
        // }

        guard let tv = nsView.documentView as? NSTextView else { return }

        if tv.string != text {
            tv.string = text
        }

        tv.isHorizontallyResizable   = !wrapLines
        tv.textContainer?.widthTracksTextView = wrapLines
        nsView.hasHorizontalScroller  = !wrapLines

        // let contentWidth = nsView.contentSize.width
        let clipWidth = nsView.contentView.bounds.width
        let containerWidth: CGFloat = wrapLines ? clipWidth : .greatestFiniteMagnitude
        tv.textContainer?.containerSize = NSSize(
            width:  containerWidth,
            height: .greatestFiniteMagnitude
        )

        // tv.layoutManager?.ensureLayout(
        //     forCharacterRange: NSRange(location: 0, length: tv.string.utf16.count),
        //     within: tv.textContainer!
        // )
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
