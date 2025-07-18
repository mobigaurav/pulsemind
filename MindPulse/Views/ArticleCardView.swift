//
//  ArticleCardView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct ArticleCardView: View {
    let article: HealthArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(article.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 240, height: 140)
                .clipped()
                .cornerRadius(12)

            Text(article.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(width: 260)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

