//
//  ChatView.swift
//  TellTrail
//
//  Created by Aakash Sinha on 12/05/26.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel

    init(viewModel: ChatViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HeaderView(title: "Chat", subtitle: "Voice replies and trail messages", actionSymbol: "square.and.pencil")

                ForEach(viewModel.threads) { chat in
                    ChatThreadRow(chat: chat)
                }

                VoiceMessagePreview()
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)
            .padding(.bottom, 110)
        }
    }
}

private struct ChatThreadRow: View {
    let chat: ChatThread

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(initials: String(chat.name.prefix(2)).uppercased(), size: 50)
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(chat.name)
                        .font(.headline.weight(.bold))
                    Spacer()
                    Text(chat.time)
                        .font(.caption)
                        .foregroundStyle(TrailTheme.secondaryText)
                }
                HStack(spacing: 8) {
                    if chat.isVoiceReply {
                        Image(systemName: "waveform")
                            .foregroundStyle(TrailTheme.cyan)
                    }
                    Text(chat.message)
                        .font(.subheadline)
                        .foregroundStyle(TrailTheme.secondaryText)
                        .lineLimit(1)
                }
            }
            if chat.unreadCount > 0 {
                Text("\(chat.unreadCount)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(TrailTheme.purple, in: Circle())
            }
        }
        .padding(14)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct VoiceMessagePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent voice reply")
                .font(.headline.weight(.bold))
            Text("Rahul replied to your drop")
                .font(.caption)
                .foregroundStyle(TrailTheme.secondaryText)
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .frame(width: 38, height: 38)
                    .background(TrailTheme.accentGradient, in: Circle())
                WaveformView(progress: 0.44, isActive: true)
                Text("0:34")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(TrailTheme.secondaryText)
            }
        }
        .padding(16)
        .background(TrailTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

