//
//  TextSheetView.swift
//  Giftor
//
//  Created by Kuldeep Bora on 07.02.26.
//

import SwiftUI

struct TextOverlayDraft: Equatable {
    var text: String
    var textPosition: TextPosition
    var textSize: TextSize
    var isBlinking: Bool
    var textColor: TextColorOption
    var textTiming: TextTiming
    
    static func == (lhs: TextOverlayDraft, rhs: TextOverlayDraft) -> Bool {
        lhs.text == rhs.text &&
        lhs.textPosition == rhs.textPosition &&
        lhs.textSize == rhs.textSize &&
        lhs.isBlinking == rhs.isBlinking &&
        lhs.textColor == rhs.textColor &&
        lhs.textTiming == rhs.textTiming
    }
}

struct TextSheetView: View {
       @Environment(\.dismiss) var dismiss
       @EnvironmentObject var iapManager: IAPManager

       // Incoming initial drafts
       @State var draft: TextOverlayDraft

      // New: allow caller to provide initial draft2
    var draft2Initial: TextOverlayDraft?
      @State private var draft2: TextOverlayDraft?

       // Only used when Plus/Pro to switch tabs
       @State private var selectedTabIndex: Int = 0

       // Auto-save handled by .onChange below, no Save button needed
    let onSave:
           (_ draft1: TextOverlayDraft, _ draft2: TextOverlayDraft?) -> Void

       @State private var showAutoSaveToast = false
       @State private var debounceTask: Task<Void, Never>?

       private var computedDraft2: TextOverlayDraft? {
           if isPaid {
               if let existing = draft2 {
                   return existing
               } else if let provided = draft2Initial {
                   return provided
               } else {
                   var copy = draft
                   copy.textPosition = .bottom     // default for text2
                   return copy
               }
           }
           return nil
       }

       private func autoSave() {
           debounceTask?.cancel()
           withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
               showAutoSaveToast = true
           }
           debounceTask = Task {
               try? await Task.sleep(for: .seconds(1.0))
               guard !Task.isCancelled else { return }
               showAutoSaveToast = false
               onSave(draft, computedDraft2)
           }
       }

    private var isPaid: Bool {
        iapManager.userPaidStatus == "pro"
    }

       // Active draft binding switches between draft and draft2 based on tab
    private var activeDraftBinding: Binding<TextOverlayDraft> {
        if isPaid && selectedTabIndex == 1 {
               // Ensure draft2 exists for paid users
            if draft2 == nil {
                if let provided = draft2Initial {
                    draft2 = provided
                   } else {
                    var copy = draft
                    copy.textPosition = .bottom     // default for text2
                    draft2 = copy
                   }
               }
            return Binding(
                get: { draft2 ?? draft },
                set: { draft2 = $0 }
               )
           } else {
            return $draft
           }
       }

    var body: some View {
        NavigationStack {
            Form {
                 if isPaid {
                    Section {
                        Picker("Text Selection", selection: $selectedTabIndex) {
                            Text("Text 1").tag(0)
                            Text("Text 2").tag(1)
                           }
                           .pickerStyle(.segmented)
                       }
                   }

                   // Text Input Section
                Section(header: Text("Text Content")) {
                    TextField(
                           "Enter text here...",
                        text: activeDraftBinding.text
                       )
                   }

                   // Font Size Selection (Segmented Style)
                Section(header: Text("Font Size")) {
                    Picker("Font Size", selection: activeDraftBinding.textSize)
                       {
                        Text("Small").tag(TextSize.small)
                        Text("Medium").tag(TextSize.medium)
                        Text("Large").tag(TextSize.large)
                       }
                       .pickerStyle(.segmented)
                   }

                   // Radio Selection (Picker with Inline Style)
                Section(header: Text("Text Position")) {
                    Picker(
                        selection: activeDraftBinding.textPosition,
                        label: EmptyView()
                       ) {
                        Text("Top").tag(TextPosition.top)
                        Text("Middle").tag(TextPosition.middle)
                        Text("Bottom").tag(TextPosition.bottom)
                       }
                       .pickerStyle(.inline)

                   }

                Section(header: Text("Blink Text")) {     //paid feature
                    Picker(
                           "Select playback speed",
                        selection: activeDraftBinding.isBlinking
                       ) {
                        Text("on").tag(true)
                        Text("off").tag(false)
                       }
                       .pickerStyle(.segmented)

                   }

                Section(header: Text("Text Timing")) {     //paid feature
                    Picker(
                           "Select text timing",
                        selection: activeDraftBinding.textTiming
                       ) {
                        Text("Full").tag(TextTiming.full)
                        Text("FirstHalf").tag(TextTiming.firstHalf)
                        Text("SecondHalf").tag(TextTiming.secondHalf)
                       }
                       .pickerStyle(.segmented)

                   }

                Section(header: Text("Text Color")) {
                    HStack {
                        TextColorSelector(
                            selectedColor: activeDraftBinding.textColor
                           )
                       }

                   }

               }
               .scrollContentBackground(.hidden)
               .navigationTitle("Add text")
               .navigationBarTitleDisplayMode(.inline)
               .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                       }
                   }
               }
               .appBackground()

               .overlay(alignment: .bottom) {
                    if showAutoSaveToast {
                        Text("Applied!")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    }
                }
                .animation(.easeInOut, value: showAutoSaveToast)

                .onChange(of: draft) { _, _ in autoSave() }
                .onChange(of: draft2) { _, _ in autoSave() }
           }
           .onAppear {
               // Initialize second draft lazily for paid users
            if isPaid && draft2 == nil {
                if let provided = draft2Initial {
                    draft2 = provided
                   } else {
                    var copy = draft
                    copy.textPosition = .bottom
                    draft2 = copy
                   }
               }
          }
      }
}

struct TextColorSelector: View {
     @Binding var selectedColor: TextColorOption

    var body: some View {
        HStack(spacing: 12) {
            ForEach(TextColorOption.allCases) { option in
                Circle()
                       .fill(option.color)
                       .frame(width: 58, height: 38)
                       .overlay(
                        Circle()
                               .stroke(
                                selectedColor == option
                                       ? Color.blue : Color.clear,
                                lineWidth: 4
                               )
                       )
                       .overlay(
                        Circle()
                               .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                       )
                       .onTapGesture {
                        selectedColor = option
                      }
               }
          }
          .padding(8)
          .background(.ultraThinMaterial)
          .clipShape(Capsule())
       }
   }

#Preview {
    TextColorSelector(selectedColor: .constant(.red))
}
