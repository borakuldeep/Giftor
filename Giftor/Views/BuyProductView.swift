import StoreKit
import SwiftUI

struct BuyProductView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var iapManager: IAPManager

    @State private var isPurchasing = false
    @State private var showThanksToast = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Spacer()

                // MARK: - Header
                VStack(spacing: 12) {
                        Text("Support the app 🍵💸")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text(
                            "Thanks for using the app. You can support me by buying me a coffee or purchasing the pro version. It only takes a few seconds."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)  // allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 12)

                //Spacer()

                // MARK: - CTA Section
                VStack(spacing: 24) {
                    // PLUS
                    VStack(spacing: 8) {
                        Button(action: {
                            guard
                                let product = iapManager.products.first(
                                    where: {
                                        $0.id == coffeeProdId
                                    })
                            else { return }

                            isPurchasing = true

                            Task {
                                _ = await iapManager.purchase(product)
                                isPurchasing = false
                                showThanksToast = true
                            }
                        }) {
                            ZStack {

                                Text("Buy me a Coffee ☕ $1.99")
                                    .font(.headline)
                                    .opacity(isPurchasing ? 0 : 1)

                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                }
                            }
                            .frame(maxWidth: .infinity) 
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(
                                            red: 0.36,
                                            green: 0.25,
                                            blue: 0.20
                                        ),  // dark espresso
                                        Color(
                                            red: 0.76,
                                            green: 0.60,
                                            blue: 0.42
                                        ),  // creamy latte
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(isPurchasing)

                        Text(
                            "If you like the app, support me by buying me a small coffee. 🍵"
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)  // allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                    }

                    if iapManager.userPaidStatus != "pro" {
                        // PRO
                        VStack(spacing: 8) {
                            Button(action: {
                                guard
                                    let product = iapManager.products.first(
                                        where: {
                                            $0.id == proUserProdId
                                        })
                                else { return }

                                isPurchasing = true

                                Task {
                                    _ = await iapManager.purchase(product)
                                    isPurchasing = false
                                    showThanksToast = true
                                }
                            }) {

                                ZStack {
                                    Text("Upgrade to Pro for $9.99")
                                        .font(.headline)
                                        .opacity(isPurchasing ? 0 : 1)

                                    if isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }
                            .disabled(isPurchasing)

                            Text(
                                "Add your own watermark"
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)  // allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 32)
                        }
                    }
                    if iapManager.userPaidStatus == "pro" {
                        Text("PRO")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.yellow)
                            )
                            .foregroundColor(.black)
                        VStack(spacing: 12) {
                            Text("PRO USER")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.yellow)
                                .multilineTextAlignment(.center)

                            Text(
                                "Enjoy your Gif creation with full freedom...more features coming!"
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)  // allow unlimited lines
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 32)
                        }
                        .padding(.bottom, 12)

                    }

                    // FEEDBACK
                    VStack(spacing: 8) {
                        Button(action: {
                            requestReview()
                        }) {
                            Text("Provide Feedback")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.15))
                                .foregroundColor(.primary)
                                .cornerRadius(14)
                        }

                        Text(
                            "Help us improve the app by sharing your ideas and suggestions."
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)  // allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.horizontal, 24)
                //.padding(.bottom, 12)

                Button("Restore purchase") {
                    isPurchasing = true
                    Task {
                        await iapManager.restorePurchases()
                        isPurchasing = false
                    }
                }
                .padding(.top, 42)

                Spacer()

            }
            .padding(.top, 10)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .appBackground()
            .overlay(alignment: .bottom) {
                if showThanksToast {
                    Text(
                        "Thanks for the support! 🙌"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(.yellow)
                    .clipShape(Capsule())
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 20)
                    .onAppear {
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation {
                                showThanksToast = false
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut, value: showThanksToast)
        }

    }
}

#Preview {
    BuyProductView()
        .environmentObject(IAPManager(preview: true))
    //.frame(width: 375, height: 812) // for 13 mini
}
