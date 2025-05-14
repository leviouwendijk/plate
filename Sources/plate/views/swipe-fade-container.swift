import SwiftUI

public struct SwipeFadeContainer<Content: View>: View {
    @ViewBuilder public let content: () -> Content
    
    public var threshold: CGFloat = 80
    public var animationDuration: Double = 0.25
    
    @State private var isVisible: Bool = true
    @GestureState private var dragOffset: CGFloat = 0
    
    public init(
        threshold: CGFloat = 80,
        animationDuration: Double = 0.25,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.threshold = threshold
        self.animationDuration = animationDuration
        self.content = content
    }
    
    public var body: some View {
        content()
            .offset(x: dragOffset)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: animationDuration), value: isVisible)
            .animation(.interactiveSpring(), value: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        // Swipe left to fade out
                        if value.translation.width < -threshold {
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                isVisible = false
                            }
                        }
                        // Swipe right to fade in
                        else if value.translation.width > threshold {
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                isVisible = true
                            }
                        }
                    }
            )
    }
}
