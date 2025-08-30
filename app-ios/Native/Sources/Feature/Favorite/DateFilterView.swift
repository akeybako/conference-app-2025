import Model
import SwiftUI
import Theme

struct DateFilterView: View {

    @Binding private var selectedDate: FavoriteDateFilter

    init(selectedDate: Binding<FavoriteDateFilter>) {
        self._selectedDate = selectedDate
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(FavoriteDateFilter.allCases, id: \.self) { filter in
                Button(
                    action: {
                        selectedDate = filter
                    },
                    label: {
                        HStack(spacing: 4) {
                            if selectedDate == filter {
                                Image(systemName: "checkmark")
                                    .font(Typography.labelSmall)
                            }
                            Text(filter.rawValue)
                                .font(Typography.labelLarge)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selectedDate == filter
                                ? AssetColors.secondaryContainer.swiftUIColor
                                : Color.clear
                        )
                        .foregroundStyle(
                            selectedDate == filter
                                ? AssetColors.onSecondaryContainer.swiftUIColor
                                : AssetColors.onSurfaceVariant.swiftUIColor
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    selectedDate == filter
                                        ? Color.clear
                                        : AssetColors.outline.swiftUIColor,
                                    lineWidth: 1
                                )
                        )
                        .cornerRadius(8)
                    }
                )
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
    }
}
