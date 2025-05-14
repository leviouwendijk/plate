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
            .contentShape(Rectangle()) 
            .offset(x: dragOffset)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: animationDuration), value: isVisible)
            .animation(.interactiveSpring(), value: dragOffset)
            .highPriorityGesture(
                DragGesture(minimumDistance: 10)
                .updating($dragOffset) { value, state, _ in
                    // only track horizontal movement
                    if abs(value.translation.width) > abs(value.translation.height) {
                        state = value.translation.width
                    }
                }
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else {
                        return // vertical swipe, ignore
                    }
                    if value.translation.width < -threshold {
                        // Swipe left: hide
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            isVisible = false
                        }
                    } else if value.translation.width > threshold {
                        // Swipe right: show
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            isVisible = true
                        }
                    }
                }
            )
    }
}
