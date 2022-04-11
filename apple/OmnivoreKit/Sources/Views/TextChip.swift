import Models
import SwiftUI
import Utils

public struct TextChip: View {
  public init(text: String, color: Color) {
    self.text = text
    self.color = color
  }

  public init?(feedItemLabel: FeedItemLabel) {
    guard let color = Color(hex: feedItemLabel.color) else { return nil }

    self.text = feedItemLabel.name
    self.color = color
  }

  let text: String
  let color: Color
  let cornerRadius = 20.0

  public var body: some View {
    Text(text)
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .font(.appFootnote)
      .foregroundColor(color.isDark ? .white : .black)
      .lineLimit(1)
      .background(color)
      .cornerRadius(cornerRadius)
  }
}

public struct TextChipButton: View {
  public static func makeAddLabelButton(onTap: @escaping () -> Void) -> TextChipButton {
    TextChipButton(title: "Label Filter", color: .appYellow48, actionType: .add, onTap: onTap)
  }

  public static func makeShowOptionsButton(title: String, onTap: @escaping () -> Void) -> TextChipButton {
    TextChipButton(title: title, color: .appButtonBackground, actionType: .add, onTap: onTap)
  }

  public static func makeRemovableLabelButton(
    feedItemLabel: FeedItemLabel,
    onTap: @escaping () -> Void
  ) -> TextChipButton {
    TextChipButton(
      title: feedItemLabel.name,
      color: Color(hex: feedItemLabel.color) ?? .appButtonBackground,
      actionType: .remove,
      onTap: onTap
    )
  }

  public enum ActionType {
    case remove
    case add
    case show

    var systemIconName: String {
      switch self {
      case .remove:
        return "xmark"
      case .add:
        return "plus"
      case .show:
        return "chevron.down"
      }
    }
  }

  init(title: String, color: Color, actionType: ActionType, onTap: @escaping () -> Void) {
    self.text = title
    self.color = color
    self.onTap = onTap
    self.actionType = actionType
  }

  let text: String
  let color: Color
  let onTap: () -> Void
  let actionType: ActionType
  let cornerRadius = 20.0

  public var body: some View {
    Button(action: onTap) {
      HStack {
        Text(text)
        Image(systemName: actionType.systemIconName)
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .font(.appFootnote)
      .foregroundColor(color.isDark ? .white : .black)
      .lineLimit(1)
      .background(color)
      .cornerRadius(cornerRadius)
    }
  }
}
