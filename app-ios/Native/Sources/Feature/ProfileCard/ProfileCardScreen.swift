import Component
import Model
import Observation
import Presentation
import SwiftUI
import Theme

public struct ProfileCardScreen: View {
    @State private var presenter = ProfileCardPresenter()

    public init() {}

    public var body: some View {
        NavigationStack {
            profileCardScrollView
                .background(AssetColors.surface.swiftUIColor)
                .navigationTitle("Profile Card")
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.large)
                #endif
                .onAppear {
                    presenter.loadInitial()
                }
        }
    }

    @ViewBuilder
    private var profileCardScrollView: some View {
        let profile = presenter.profile.profile
        let isLoading = presenter.profile.isLoading
        ScrollView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if presenter.shouldEditing {
                    editView
                } else if let profile = profile {
                    cardView(profile)
                } else {
                    Text("No profile data available")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 80)  // Tab bar padding
        }
    }

    private var editView: some View {
        EditProfileCardForm(presenter: $presenter)
    }

    @ViewBuilder
    private func cardView(_ profile: Model.Profile) -> some View {
        VStack(spacing: 0) {
            profileCard(profile)
            actionButtons
        }
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private func profileCard(_ profile: Model.Profile) -> some View {
        TiltFlipCard(
            front: { normal in
                FrontCard(
                    userRole: profile.occupation,
                    userName: profile.name,
                    cardType: profile.cardVariant.type,
                    image: profile.image,
                    normal: (normal.x, normal.y, normal.z),
                )
            },
            back: { normal in
                BackCard(
                    cardType: profile.cardVariant.type,
                    url: profile.url,
                    normal: (normal.x, normal.y, normal.z),
                )
            }
        )
        .padding(.horizontal, 56)
        .padding(.vertical, 32)
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            shareButton
            editButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var shareButton: some View {
        Group {
            if let profile = presenter.profile.profile,
                let uiImage = OGPProfileShareImage(profile: profile).render(),
                let ogpImage = uiImage.pngData()
            {
                let shareText = String(localized: "Share Message", bundle: .module)
                ShareLink(
                    item: ShareOGPItem(ogpImage: ogpImage),
                    message: Text(shareText),
                    preview: SharePreview(shareText, image: Image(uiImage: uiImage))
                ) {
                    HStack {
                        AssetImages.icShare.swiftUIImage
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text(String(localized: "Share", bundle: .module))
                    }
                    .frame(maxWidth: .infinity)
                }
                .filledButtonStyle()
            } else {
                Button(action: {}) {
                    HStack {
                        AssetImages.icShare.swiftUIImage
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text(String(localized: "Share", bundle: .module))
                    }
                    .frame(maxWidth: .infinity)
                }
                .filledButtonStyle()
                .disabled(true)
            }
        }
    }

    private var editButton: some View {
        Button {
            presenter.editProfile()
        } label: {
            Text(String(localized: "Edit", bundle: .module))
                .frame(maxWidth: .infinity)
        }
        .textButtonStyle()
    }
}

struct ShareOGPItem: Transferable {
    let ogpImage: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .png) { shareOGP in
            shareOGP.ogpImage
        }
    }
}

#Preview {
    ProfileCardScreen()
}
