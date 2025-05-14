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
      // ZStack to layer the overlay above your content
      ZStack {
        content()
          .offset(x: dragOffset)
          .opacity(isVisible ? 1 : 0)
          .animation(.easeInOut(duration: animationDuration), value: isVisible)
          .animation(.interactiveSpring(),                 value: dragOffset)
      }
      // Transparent “hit‐area” on top of everything
      .overlay(
        Color.clear
          .contentShape(Rectangle())  // Make full area tappable
          .gesture(
            DragGesture(minimumDistance: 10)
              .updating($dragOffset) { v, state, _ in
                if abs(v.translation.width) > abs(v.translation.height) {
                  state = v.translation.width
                }
              }
              .onEnded { v in
                guard abs(v.translation.width) > abs(v.translation.height) else { return }
                if v.translation.width < -threshold {
                  withAnimation(.easeInOut(duration: animationDuration)) {
                    isVisible = false
                  }
                } else if v.translation.width > threshold {
                  withAnimation(.easeInOut(duration: animationDuration)) {
                    isVisible = true
                  }
                }
              }
          )
      )
    }
}
