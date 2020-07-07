// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum FactsList {
    /// Try again
    internal static let retryButton = L10n.tr("Localizable", "FactsList.retryButton")
    /// Norris Facts
    internal static let title = L10n.tr("Localizable", "FactsList.title")
  }

  internal enum Errors {
    /// There is no internet connection. Please turn on your Wi-fi or 4G.
    internal static let noInternetConnection = L10n.tr("Localizable", "errors.noInternetConnection")
    /// Service unavailable.\nTry again later!
    internal static let unknow = L10n.tr("Localizable", "errors.unknow")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
