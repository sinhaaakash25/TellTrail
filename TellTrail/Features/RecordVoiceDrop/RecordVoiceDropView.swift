import PhotosUI
import SwiftUI
import UIKit

struct RecordVoiceDropView: View {
    @StateObject private var viewModel: RecordVoiceDropViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedVideoItem: PhotosPickerItem?
    @FocusState private var focusedField: RecordFocusField?

    init(viewModel: RecordVoiceDropViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                RecordHeader(isDisabled: viewModel.isSaved) {
                    viewModel.deleteDraft()
                    selectedPhotoItem = nil
                    selectedVideoItem = nil
                }

                PrimaryRecorderPanel(
                    isRecording: viewModel.isRecording,
                    hasRecording: viewModel.hasRecording,
                    isPreviewing: viewModel.isPreviewing,
                    durationText: viewModel.durationText,
                    progress: viewModel.recordingProgress,
                    onRecord: viewModel.toggleRecording,
                    onPreview: viewModel.previewRecording,
                    onRetake: viewModel.retakeRecording
                )

                DropDetailsSection(
                    title: $viewModel.title,
                    caption: $viewModel.caption,
                    locationName: $viewModel.locationName,
                    focusedField: $focusedField
                )

                MediaSection(
                    selectedPhotoItem: $selectedPhotoItem,
                    selectedVideoItem: $selectedVideoItem,
                    photoAttachmentName: viewModel.photoAttachmentName,
                    videoAttachmentName: viewModel.videoAttachmentName,
                    onRemovePhoto: viewModel.removePhoto,
                    onRemoveVideo: viewModel.removeVideo
                )

                PublishSettingsSection(
                    ranges: viewModel.ranges,
                    visibilityOptions: viewModel.visibilityOptions,
                    selectedRange: $viewModel.selectedRange,
                    selectedVisibility: $viewModel.selectedVisibility
                )

                Button {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        viewModel.saveDrop()
                        focusedField = nil
                        selectedPhotoItem = nil
                        selectedVideoItem = nil
                    }
                } label: {
                    SaveButtonLabel(isSaved: viewModel.isSaved, canSave: viewModel.canSave)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canSave || viewModel.isSaved)
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 280)
                .allowsHitTesting(!viewModel.isSaved)
                .animation(.easeInOut(duration: 0.24), value: viewModel.isSaved)
            }
            .onChange(of: focusedField) { _, field in
                guard let field else { return }
                withAnimation(.easeOut(duration: 0.22)) {
                    proxy.scrollTo(field, anchor: .center)
                }
            }
        }
        .background(TrailTheme.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                let data = try? await newItem?.loadTransferable(type: Data.self)
                await MainActor.run {
                    viewModel.attachPhotoData(data ?? nil)
                }
            }
        }
        .onChange(of: selectedVideoItem) { _, newItem in
            if newItem != nil {
                viewModel.attachVideo()
            }
        }
    }
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private enum RecordFocusField: Hashable {
    case title
    case location
    case caption
}

private struct SaveButtonLabel: View {
    let isSaved: Bool
    let canSave: Bool

    var body: some View {
        ZStack {
            Label("Save", systemImage: "checkmark.circle")
                .opacity(isSaved ? 0 : 1)
                .scaleEffect(isSaved ? 0.96 : 1)
            Label("Saved", systemImage: "checkmark.circle.fill")
                .opacity(isSaved ? 1 : 0)
                .scaleEffect(isSaved ? 1 : 0.96)
        }
        .font(.headline.weight(.bold))
        .foregroundStyle(foregroundStyle)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(backgroundStyle, in: Capsule())
        .overlay(Capsule().stroke(borderColor, lineWidth: 1))
        .animation(.easeInOut(duration: 0.24), value: isSaved)
        .animation(.easeInOut(duration: 0.18), value: canSave)
    }

    private var foregroundStyle: Color {
        if isSaved { return TrailTheme.green }
        return canSave ? .white : TrailTheme.secondaryText
    }

    private var backgroundStyle: AnyShapeStyle {
        if isSaved { return AnyShapeStyle(TrailTheme.surface) }
        return canSave ? AnyShapeStyle(TrailTheme.accentGradient) : AnyShapeStyle(TrailTheme.surface)
    }

    private var borderColor: Color {
        if isSaved { return TrailTheme.green.opacity(0.45) }
        return canSave ? .clear : TrailTheme.border
    }
}

private struct SplitHeaderTitle: View {
    let primary: String
    let accent: String

    var body: some View {
        HStack(spacing: 0) {
            Text(primary)
                .foregroundStyle(.white)
            Text(accent)
                .foregroundStyle(TrailTheme.green)
        }
        .font(.title2.weight(.black))
        .lineLimit(1)
        .minimumScaleFactor(0.82)
        .accessibilityLabel(primary + accent)
    }
}

private struct RecordHeader: View {
    let isDisabled: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                SplitHeaderTitle(primary: "Re", accent: "cord")
                Text("Record first. Add context after.")
                    .font(.subheadline)
                    .foregroundStyle(TrailTheme.secondaryText)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.headline)
                    .foregroundStyle(TrailTheme.orange)
                    .frame(width: 44, height: 44)
                    .background(TrailTheme.surface, in: Circle())
                    .overlay(Circle().stroke(TrailTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.45 : 1)
            .accessibilityLabel("Delete draft")
        }
    }
}

private struct PrimaryRecorderPanel: View {
    let isRecording: Bool
    let hasRecording: Bool
    let isPreviewing: Bool
    let durationText: String
    let progress: Double
    let onRecord: () -> Void
    let onPreview: () -> Void
    let onRetake: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                Button(action: onRecord) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? TrailTheme.orange.opacity(0.18) : TrailTheme.subtleFill)
                            .frame(width: 96, height: 96)
                        Circle()
                            .fill(isRecording ? AnyShapeStyle(TrailTheme.orange) : AnyShapeStyle(TrailTheme.elevated))
                            .frame(width: 72, height: 72)
                            .overlay(Circle().stroke(isRecording ? Color.clear : TrailTheme.border, lineWidth: 1))
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(isRecording ? .white : TrailTheme.primaryText)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")

                VStack(alignment: .leading, spacing: 8) {
                    Text(isRecording ? "Recording" : hasRecording ? "Recording saved" : "Ready to record")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(TrailTheme.primaryText)
                    Text(isRecording ? "Speak clearly. Tap stop when done." : "Your voice note is the main content of the drop.")
                        .font(.subheadline)
                        .foregroundStyle(TrailTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(durationText)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(TrailTheme.primaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            RecordProgressLine(progress: hasRecording || isRecording ? max(progress, 0.08) : 0, isActive: isRecording || hasRecording)
                .padding(.vertical, 8)

            HStack(spacing: 10) {
                Button(action: onPreview) {
                    CompactButton(title: isPreviewing ? "Stop" : "Preview", symbol: isPreviewing ? "stop.fill" : "play.fill", style: .secondary)
                }
                .buttonStyle(.plain)
                .disabled(!hasRecording)
                .opacity(hasRecording ? 1 : 0.45)

                Button(action: onRetake) {
                    CompactButton(title: "Retake", symbol: "arrow.counterclockwise", style: .secondary)
                }
                .buttonStyle(.plain)
                .disabled(!hasRecording && !isRecording)
                .opacity(hasRecording || isRecording ? 1 : 0.45)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isRecording ? TrailTheme.orange.opacity(0.42) : TrailTheme.border, lineWidth: 1)
        )
    }
}

private struct RecordProgressLine: View {
    let progress: Double
    let isActive: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(TrailTheme.subtleFill)
                Capsule()
                    .fill(isActive ? TrailTheme.cyan : TrailTheme.secondaryText.opacity(0.32))
                    .frame(width: proxy.size.width * max(0, min(progress, 1)))
            }
        }
        .frame(height: 3)
    }
}

private struct DropDetailsSection: View {
    @Binding var title: String
    @Binding var caption: String
    @Binding var locationName: String
    var focusedField: FocusState<RecordFocusField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Details", symbol: "text.alignleft")
            FormTextField(title: "Title", placeholder: "Name this voice note", text: $title, symbol: "textformat", focus: .title, focusedField: focusedField)
                .id(RecordFocusField.title)
            FormTextField(title: "Location", placeholder: "Add location", text: $locationName, symbol: "mappin.and.ellipse", focus: .location, focusedField: focusedField)
                .id(RecordFocusField.location)
            FormTextEditor(title: "Caption", placeholder: "Add context, tags, or a creator offer", text: $caption, focusedField: focusedField)
                .id(RecordFocusField.caption)
        }
        .sectionCard()
    }
}

private struct MediaSection: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedVideoItem: PhotosPickerItem?
    let photoAttachmentName: String?
    let videoAttachmentName: String?
    let onRemovePhoto: () -> Void
    let onRemoveVideo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Media", symbol: "photo.on.rectangle")
            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    MediaAttachBox(symbol: "photo.fill", title: "Photo", attachmentName: photoAttachmentName)
                }
                .buttonStyle(.plain)

                MediaAttachBox(symbol: "video.slash.fill", title: "Video disabled", attachmentName: nil)
                    .opacity(0.46)
                    .accessibilityLabel("Video attachment disabled")
            }

            if photoAttachmentName != nil {
                HStack(spacing: 10) {
                    AttachmentPill(title: "Photo", symbol: "photo.fill", onRemove: onRemovePhoto)
                }
            }
        }
        .sectionCard()
    }
}

private struct PublishSettingsSection: View {
    let ranges: [String]
    let visibilityOptions: [String]
    @Binding var selectedRange: String
    @Binding var selectedVisibility: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Publish", symbol: "slider.horizontal.3")
            VStack(alignment: .leading, spacing: 8) {
                Text("Range")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TrailTheme.primaryText)
                PickerRow(options: ranges, selected: $selectedRange)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Visibility")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TrailTheme.primaryText)
                PickerRow(options: visibilityOptions, selected: $selectedVisibility)
            }
        }
        .sectionCard()
    }
}

private struct SectionTitle: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.headline.weight(.bold))
            .foregroundStyle(TrailTheme.primaryText)
    }
}

private struct FormTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let symbol: String
    let focus: RecordFocusField
    var focusedField: FocusState<RecordFocusField?>.Binding

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(TrailTheme.cyan)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(TrailTheme.secondaryText)
                TextField(placeholder, text: $text)
                    .focused(focusedField, equals: focus)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TrailTheme.primaryText)
            }
        }
        .inputSurface()
    }
}

private struct FormTextEditor: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var focusedField: FocusState<RecordFocusField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TrailTheme.secondaryText)
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundStyle(TrailTheme.secondaryText.opacity(0.72))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                TextEditor(text: $text)
                    .focused(focusedField, equals: .caption)
                    .font(.subheadline)
                    .foregroundStyle(TrailTheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 88)
            }
        }
        .inputSurface()
    }
}

private struct MediaAttachBox: View {
    let symbol: String
    let title: String
    let attachmentName: String?

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: attachmentName == nil ? symbol : "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(attachmentName == nil ? TrailTheme.cyan : TrailTheme.green)
            Text(attachmentName ?? title)
                .font(.caption.weight(.bold))
                .foregroundStyle(TrailTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 86)
        .background(TrailTheme.elevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(TrailTheme.border, lineWidth: 1))
    }
}

private struct AttachmentPill: View {
    let title: String
    let symbol: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
            Text(title)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
            }
            .buttonStyle(.plain)
        }
        .font(.caption.weight(.bold))
        .foregroundStyle(TrailTheme.primaryText)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(TrailTheme.subtleFill, in: Capsule())
    }
}

private enum StatusStyle {
    case error
    case success
}

private struct StatusMessage: View {
    let message: String?
    let style: StatusStyle

    var body: some View {
        if let message {
            Label(message, systemImage: style == .error ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(style == .error ? TrailTheme.orange : TrailTheme.green)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TrailTheme.border, lineWidth: 1))
        }
    }
}

private struct PickerRow: View {
    let options: [String]
    @Binding var selected: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    selected = option
                } label: {
                    Text(option)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(option == selected ? TrailTheme.primaryText : TrailTheme.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(option == selected ? TrailTheme.subtleFill : TrailTheme.elevated, in: Capsule())
                        .overlay(Capsule().stroke(option == selected ? TrailTheme.cyan.opacity(0.5) : TrailTheme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private extension View {
    func sectionCard() -> some View {
        padding(16)
            .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(TrailTheme.border, lineWidth: 1))
    }

    func inputSurface() -> some View {
        padding(12)
            .background(TrailTheme.elevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(TrailTheme.border, lineWidth: 1))
    }
}
