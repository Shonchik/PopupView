//
//  Constructors.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

public typealias SendableClosure = @Sendable @MainActor () -> Void

struct PopupDismissKey: EnvironmentKey {
    static let defaultValue: SendableClosure? = nil
}

public extension EnvironmentValues {
    var popupDismiss: SendableClosure? {
        get { self[PopupDismissKey.self] }
        set { self[PopupDismissKey.self] = newValue }
    }
}

@MainActor
extension View {
    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        customize: @escaping (Popup<PopupContent, EmptyView>.PopupParameters) -> Popup<PopupContent, EmptyView>.ScrollPopupParameters
        ) -> some View {
            let params = customize(Popup<PopupContent, EmptyView>.PopupParameters())
            params.isScrollPopup = false
            return self.modifier(
                FullscreenPopup<Int, PopupContent, EmptyView>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: params,
                    view: view,
                    headerView: nil,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        customize: @escaping (Popup<PopupContent, EmptyView>.PopupParameters) -> Popup<PopupContent, EmptyView>.ScrollPopupParameters
        ) -> some View {
            let params = customize(Popup<PopupContent, EmptyView>.PopupParameters())
            params.isScrollPopup = false
            return self.modifier(
                FullscreenPopup<Item, PopupContent, EmptyView>(
                    item: item,
                    isBoolMode: false,
                    params: params,
                    view: nil,
                    headerView: nil,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            let params = Popup<PopupContent, EmptyView>.ScrollPopupParameters()
            params.isScrollPopup = false
            return self.modifier(
                FullscreenPopup<Int, PopupContent, EmptyView>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: params,
                    view: view,
                    headerView: nil,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent) -> some View {
            let params = Popup<PopupContent, EmptyView>.ScrollPopupParameters()
            params.isScrollPopup = false
            return self.modifier(
                FullscreenPopup<Item, PopupContent, EmptyView>(
                    item: item,
                    isBoolMode: false,
                    params: params,
                    view: nil,
                    headerView: nil,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }

#if os(iOS)
// MARK: ScrollablePopup
    public func scrollablePopup<PopupContent: View, HeaderContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        @ViewBuilder headerView: @escaping () -> HeaderContent,
        customize: @escaping (Popup<PopupContent, HeaderContent>.ScrollPopupParameters) -> Popup<PopupContent, HeaderContent>.ScrollPopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent, HeaderContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: customize(Popup<PopupContent, HeaderContent>.ScrollPopupParameters()),
                    view: view,
                    headerView: headerView,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func scrollablePopup<Item: Equatable, PopupContent: View, HeaderContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        @ViewBuilder headerView: @escaping () -> HeaderContent,
        customize: @escaping (Popup<PopupContent, HeaderContent>.ScrollPopupParameters) -> Popup<PopupContent, HeaderContent>.ScrollPopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent, HeaderContent>(
                    item: item,
                    isBoolMode: false,
                    params: customize(Popup<PopupContent, HeaderContent>.ScrollPopupParameters()),
                    view: nil,
                    headerView: headerView,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }

    public func scrollablePopup<PopupContent: View, HeaderContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        @ViewBuilder headerView: @escaping () -> HeaderContent) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent, HeaderContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: Popup<PopupContent, HeaderContent>.ScrollPopupParameters(),
                    view: view,
                    headerView: headerView,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func scrollablePopup<Item: Equatable, PopupContent: View, HeaderContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        @ViewBuilder headerView: @escaping () -> HeaderContent) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent, HeaderContent>(
                    item: item,
                    isBoolMode: false,
                    params: Popup<PopupContent, HeaderContent>.ScrollPopupParameters(),
                    view: nil,
                    headerView: headerView,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }

#endif
}

#if os(iOS)

@MainActor
extension View {
    func onOrientationChange(isLandscape: Binding<Bool>, onOrientationChange: @escaping () -> Void) -> some View {
        self.modifier(OrientationChangeModifier(isLandscape: isLandscape, onOrientationChange: onOrientationChange))
    }
}

@MainActor
struct OrientationChangeModifier: ViewModifier {
    @Binding var isLandscape: Bool
    let onOrientationChange: () -> Void
    
    func body(content: Content) -> some View {
        content
#if os(iOS)
            .onReceive(NotificationCenter.default
                .publisher(for: UIDevice.orientationDidChangeNotification)
                .receive(on: DispatchQueue.main)
            ) { _ in
                updateOrientation()
            }
#endif
//            .onAppear {
//#if os(iOS)
//                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
//                    DispatchQueue.main.async {
//                        updateOrientation()
//                    }
//                }
//                updateOrientation()
//#endif
//            }
//            .onDisappear {
//                #if os(iOS)
//                NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
//                #endif
//            }
            .onChange(of: isLandscape) { _ in
                onOrientationChange()
            }
    }

#if os(iOS)
    private func updateOrientation() {
        let newIsLandscape = UIDevice.current.orientation.isLandscape
        if newIsLandscape != isLandscape {
            isLandscape = newIsLandscape
            onOrientationChange()
        }
    }
#endif
}

#endif
