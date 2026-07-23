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
      @State private var originalSnapshot: TextOverlayDraft? = nil

      // New: allow caller to provide initial draft2
    var draft2Initial: TextOverlayDraft?
      @State private var draft2: TextOverlayDraft?
      @State private var initialDraft2Snapshot: TextOverlayDraft? = nil

       // Only used when Plus/Pro to switch tabs
       @State private var selectedTabIndex: Int = 0

       // Updated to return both drafts
    let onSave:
           (_ draft1: TextOverlayDraft, _ draft2: TextOverlayDraft?) -> Void

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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                           // For paid users, pass both drafts; for free, pass only draft1
                        let d1 = draft
                        let d2: TextOverlayDraft? = {
                            guard isPaid else { return nil }
                            if let existing = draft2 {
                                return existing
                               } else if let provided = draft2Initial {
                                return provided
                               } else {
                                var copy = draft
                                copy.textPosition = .bottom     // default for text2
                                return copy
                               }
                           }()
                        onSave(d1, d2)
                       }
                       .foregroundStyle(.black)
                       .buttonStyle(.borderedProminent)
                       .padding(.horizontal)
                        // Only enable when at least one draft differs from its initial state
                       .disabled(
                            isPaid 
                                ? (draft == originalSnapshot && draft2 == initialDraft2Snapshot)
                                : (draft == originalSnapshot)
                        )
                   }
               }
               .appBackground()
           }
           .onAppear {
              // Initialize snapshot for dirty-checking on sheet presentation
            if originalSnapshot == nil {
               originalSnapshot = draft
              }
            
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
              
               // Capture initial state for Text 2 whenever it exists and hasn't been captured yet
            if draft2 != nil && initialDraft2Snapshot == nil {
                initialDraft2Snapshot = draft2
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
