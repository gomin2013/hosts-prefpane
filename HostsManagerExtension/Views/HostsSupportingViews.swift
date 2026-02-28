//
//  HostsSupportingViews.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import SwiftUI

// MARK: - Stat Item

struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Empty Detail View

struct EmptyDetailView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "network")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            Text("Select an Entry")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose a host entry from the list to view details")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No entry selected. Choose a host entry from the list to view details.")
    }
}
