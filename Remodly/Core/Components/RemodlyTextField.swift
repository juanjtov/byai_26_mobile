import SwiftUI

/// Remodly-styled text field component
struct RemodlyTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isError: Bool = false
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: RemodlySpacing.xs) {
            HStack(spacing: RemodlySpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.remodlyBody(17))
                        .foregroundColor(iconColor)
                        .frame(width: 20)
                }

                Group {
                    if isSecure {
                        SecureField("", text: $text, prompt: placeholderText)
                    } else {
                        TextField("", text: $text, prompt: placeholderText)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(autocapitalization)
                    }
                }
                .font(.remodlyBody)
                .foregroundColor(.ivory)
                .focused($isFocused)
            }
            .padding(.horizontal, RemodlySpacing.md)
            .padding(.vertical, 12)
            .background(Color.ivorySubtle)
            .overlay(
                RoundedRectangle(cornerRadius: RemodlyRadius.medium)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: RemodlyRadius.medium))

            if let errorMessage = errorMessage, isError {
                Text(errorMessage)
                    .font(.remodlyCaption)
                    .foregroundColor(.errorText)
            }
        }
    }

    private var placeholderText: Text {
        Text(placeholder)
            .foregroundColor(.ivoryPlaceholder)
    }

    private var iconColor: Color {
        if isError {
            return .errorText
        }
        return isFocused ? .copper : .bodyText
    }

    private var borderColor: Color {
        if isError {
            return .errorBorder
        }
        return isFocused ? .copper : .ivoryBorder
    }
}

/// Remodly-styled secure text field for passwords
struct RemodlySecureField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = "lock"
    var isError: Bool = false
    var errorMessage: String? = nil

    @State private var isSecure = true

    var body: some View {
        VStack(alignment: .leading, spacing: RemodlySpacing.xs) {
            HStack(spacing: RemodlySpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.remodlyBody(17))
                        .foregroundColor(.bodyText)
                        .frame(width: 20)
                }

                Group {
                    if isSecure {
                        SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.ivoryPlaceholder))
                    } else {
                        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.ivoryPlaceholder))
                    }
                }
                .font(.remodlyBody)
                .foregroundColor(.ivory)

                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .font(.remodlyBody(17))
                        .foregroundColor(.bodyText)
                }
            }
            .padding(.horizontal, RemodlySpacing.md)
            .padding(.vertical, 12)
            .background(Color.ivorySubtle)
            .overlay(
                RoundedRectangle(cornerRadius: RemodlyRadius.medium)
                    .stroke(isError ? Color.errorBorder : Color.ivoryBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: RemodlyRadius.medium))

            if let errorMessage = errorMessage, isError {
                Text(errorMessage)
                    .font(.remodlyCaption)
                    .foregroundColor(.errorText)
            }
        }
    }
}

// MARK: - Previews

#Preview("Text Fields") {
    VStack(spacing: 20) {
        RemodlyTextField(
            placeholder: "Email address",
            text: .constant(""),
            icon: "envelope"
        )

        RemodlyTextField(
            placeholder: "Search...",
            text: .constant("bathroom"),
            icon: "magnifyingglass"
        )

        RemodlyTextField(
            placeholder: "Enter value",
            text: .constant(""),
            isError: true,
            errorMessage: "This field is required"
        )

        RemodlySecureField(
            placeholder: "Password",
            text: .constant("")
        )
    }
    .padding()
    .background(Color.obsidian)
}
