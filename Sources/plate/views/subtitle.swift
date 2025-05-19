// import Foundation
// import SwiftUI

// public struct SectionTitle: View {
//     public let title: String
//     public let width: CGFloat
//     public let fontSize: CGFloat

//     public init(
//         title: String,
//         width: CGFloat = 350,
//         fontSize: CGFloat = 18
//     ) {
//         self.title = title
//         self.width = width
//         self.fontSize = fontSize
//     }

//     public var body: some View {
//         VStack(alignment: .center) {
//             Text(title)
//                 .font(.system(size: fontSize, weight: .semibold, design: .rounded))
//                 .fontWeight(.semibold)
//                 .foregroundColor(.secondary)
//                 .padding(.horizontal, 8)
//                 .frame(maxWidth: width)

//             line
//         }
//         .padding(.vertical, 8)
//     }

//     private var line: some View {
//         Rectangle()
//             .frame(height: 1)
//             .foregroundColor(Color.secondary.opacity(0.5))
//             .frame(maxWidth: width)
//     }
// }
