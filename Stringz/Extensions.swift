//
//  Extensions.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/22/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import ObjectiveC
import Foundation
import Cocoa
import XcodeProj

public extension Sequence {
  func categorise<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
    var dict: [U: [Iterator.Element]] = [:]
    for el in self {
      let key = key(el)
      if case nil = dict[key]?.append(el) { dict[key] = [el] }
    }
    return dict
  }
}

enum PBXFileType {
  case strings
  case stringsDict
  case storyboard
  case xib
  case plist
  case swift
  case assetsCatalog
  case header
  case objC
  case framework
  case config
  case unknown
}

extension PBXFileReference {
  var fileType: PBXFileType {
    guard let fileType = lastKnownFileType ?? explicitFileType else { return .unknown }

    switch fileType.lowercased() {
    case let type where type.contains(".storyboard"):
      return .storyboard
    case let type where type.contains(".stringsdict"):
      return .stringsDict
    case let type where type.contains(".strings"):
      return .strings
    case let type where type.contains(".xib"):
      return .xib
    case let type where type.contains(".plist.xml"):
      return .plist
    case let type where type.contains(".swift"):
      return .swift
    case let type where type.contains(".xcconfig"):
      return .config
    case let type where type.contains(".assetcatalog"):
      return .assetsCatalog
    case let type where type.contains(".c.h"):
      return .header
    case let type where type.contains(".c.objc"):
      return .objC
    case let type where type.contains(".framework"):
      return .framework
    default:
      return .unknown
    }
  }
}

extension StringProtocol {
  func index<S: StringProtocol>(of string: S, options: String.CompareOptions = [], locale: Locale? = nil) -> Index? {
    range(of: string, options: options, locale: locale)?.lowerBound
  }

  func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = [], locale: Locale? = nil) -> Index? {
    range(of: string, options: options, locale: locale)?.upperBound
  }

  func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = [], locale: Locale? = nil) -> [Index] {
    ranges(of: string, options: options, locale: locale).map(\.lowerBound)
  }

  func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
    var result: [Range<Index>] = []
    var startIndex = self.startIndex
    while startIndex < endIndex,
          let range = self[startIndex...]
            .range(of: string, options: options, locale: locale) {
      result.append(range)
      startIndex = range.lowerBound < range.upperBound ? range.upperBound :
        index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
    }
    return result
  }
}

extension MutableCollection where Self : RandomAccessCollection {

  /// Sort `self` in-place using criteria stored in a NSSortDescriptors array
  public mutating func sort(sortDescriptors theSortDescs: [NSSortDescriptor]) {
    sort { by:
      for sortDesc in theSortDescs {
      switch sortDesc.compare($0, to: $1) {
      case .orderedAscending: return sortDesc.ascending ? true : false
      case .orderedDescending: return sortDesc.ascending ? false : true
      case .orderedSame: continue
      }
    }
      return false
    }

  }
}

extension Sequence where Iterator.Element : AnyObject {

  /// Return an `Array` containing the sorted elements of `source`
  /// using criteria stored in a NSSortDescriptors array.
  public func sorted(sortDescriptors theSortDescs: [NSSortDescriptor]) -> [Self.Iterator.Element] {
    return sorted {
      for sortDesc in theSortDescs {
        switch sortDesc.compare($0, to: $1) {
        case .orderedAscending: return sortDesc.ascending ? true : false
        case .orderedDescending: return sortDesc.ascending ? false : true
        case .orderedSame: continue
        }
      }
      return false
    }
  }
}

class VSSortDescriptor: NSSortDescriptor {
  override func compare(_ lhs: Any, to rhs: Any) -> ComparisonResult {
    guard let key = self.key, let lhs = lhs as? ValueSet, let rhs = rhs as? ValueSet else { return .orderedSame }

    if key == "key" {
      return lhs.key.localizedCaseInsensitiveCompare(rhs.key)
    } else if let language = Language(rawValue: key) {
      let lhs = lhs.value(for: language)?.value ?? ""
      let rhs = rhs.value(for: language)?.value ?? ""
      return lhs.localizedCaseInsensitiveCompare(rhs)
    }

    return .orderedSame
  }
}

extension String {

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }

    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }

    func removeFileHeader() -> String {
        return replacingOccurrences(of: "file://", with: "")
    }

    func removeBraces() -> String? {
        return replacingOccurrences(of: "（", with: "(").components(separatedBy: "(").first
    }

    var localizedFormat: String {
        return self.replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: "，", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .components(separatedBy: " ")
            .map({ $0.localizedCapitalized })
            .joined(separator: "")
            .firstCharLower
    }

    var firstCharLower: String {

        guard let chr = self.first else { return self }

        let str = String(chr)
        let upper = str.lowercased()
        if upper != str {
            let result = upper + self[1..<self.count]
            return result
        }
        return self
    }


    subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound, limitedBy: self.endIndex) ?? self.endIndex
        let end = self.index(self.startIndex, offsetBy: r.upperBound, limitedBy: self.endIndex) ?? self.endIndex
        return String(self[start..<end])
    }

    subscript (n:Int) -> String {
        return self[n..<n+1]
    }
    subscript (str:String) -> Range<Index>? {
        return self.range(of: str)
    }
}
