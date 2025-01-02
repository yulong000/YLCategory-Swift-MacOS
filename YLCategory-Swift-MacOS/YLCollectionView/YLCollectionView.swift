//
//  YLCollectionView.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/27.
//

import Foundation

open class YLCollectionView: NSView, NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    
    public private(set) var collectionView: NSCollectionView = NSCollectionView()
    public private(set) var scrollView: NSScrollView = NSScrollView()
    private lazy var clipView: YLCollectionClipView = {
        let clipView = YLCollectionClipView()
        clipView.postsBoundsChangedNotifications = true
        return clipView
    }()
    
    // MARK: - 构造方法
    
    convenience init(layout: NSCollectionViewLayout) {
        self.init(frame: .zero)
        setupCollectionView()
        collectionView.collectionViewLayout = layout
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupCollectionView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupCollectionView() {
        scrollView.contentView = clipView
        scrollView.documentView = collectionView
        scrollView.borderType = .noBorder
        scrollView.contentInsets = NSEdgeInsetsZero
        scrollView.drawsBackground = false
        scrollView.autoresizingMask = [.width, .height]
        addSubview(scrollView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = true
        collectionView.isSelectable = true
        collectionView.backgroundColors = [.clear]
        
        NotificationCenter.default.addObserver(self, selector: #selector(clipViewBoundsChanged(_:)), name: NSView.boundsDidChangeNotification, object: self.scrollView.contentView)
    }
    
    @objc private func clipViewBoundsChanged(_ notification: Notification) {
        if notification.object as? NSClipView == scrollView.contentView {
            scrollHandler?(scrollView, collectionView)
        }
    }
    
    public override func layout() {
        super.layout()
        scrollView.frame = bounds
    }
    
    // MARK: - 注册
    
    // MARK: 注册item
    public func registerItem(_ itemClass: AnyClass?, withIdentifier identifier: NSUserInterfaceItemIdentifier) {
        collectionView.register(itemClass, forItemWithIdentifier: identifier)
    }
    
    // MARK: 注册header，footer
    public func registerSupplementary(_ viewClass: AnyClass?, kind: NSCollectionView.SupplementaryElementKind, withIdentifier identifier: NSUserInterfaceItemIdentifier) {
        collectionView.register(viewClass, forSupplementaryViewOfKind: kind, withIdentifier: identifier)
    }
    
    // MARK: 注册 NIB item
    public func registerItemNib(_ nib: NSNib?, withIdentifier identifier: NSUserInterfaceItemIdentifier) {
        collectionView.register(nib, forItemWithIdentifier: identifier)
    }
    
    // MARK: 注册 NIB header，footer
    public func registerSupplementaryNib(_ nib: NSNib?, kind: NSCollectionView.SupplementaryElementKind, withIdentifier identifier: NSUserInterfaceItemIdentifier) {
        collectionView.register(nib, forSupplementaryViewOfKind: kind, withIdentifier: identifier)
    }
    
    // MARK: 注册拖拽类型
    public override func registerForDraggedTypes(_ types: [NSPasteboard.PasteboardType]) {
        collectionView.registerForDraggedTypes(types)
    }
    
    // MARK: 重新加载数据
    public func reloadData() {
        collectionView.reloadData()
    }
    
    
    // MARK: - dataSource
    
    /// 返回分组个数，默认1
    public var numberOfSectionsHandler: ((NSCollectionView) -> Int)?
    /// 返回每个分组item的个数
    public var numberOfItemsHandler: ((NSCollectionView, Int) -> Int)?
    /// 返回item对象
    public var itemHandler: ((NSCollectionView, IndexPath) -> NSCollectionViewItem)?
    /// 返回header & footer
    public var supplementaryViewHandler: ((NSCollectionView, NSCollectionView.SupplementaryElementKind, IndexPath) -> NSView?)?
    
    
    // MARK: - delegate
    
    /// 将要选中回调
    public var shouldSelectHandler: ((NSCollectionView, Set<IndexPath>) -> Set<IndexPath>)?
    /// 选中回调
    public var selectHandler: ((NSCollectionView, Set<IndexPath>) -> Void)?
    /// 将要取消选中回调
    public var shouldDeselectHandler: ((NSCollectionView, Set<IndexPath>) -> Set<IndexPath>)?
    /// 取消选中回调
    public var deselectHandler: ((NSCollectionView, Set<IndexPath>) -> Void)?
    /// 滚动回调
    public var scrollHandler: ((NSScrollView, NSCollectionView) -> Void)?
    
    // MARK: - 拖拽
    
    /// 是否可以拖拽
    public var canDragHandler: ((NSCollectionView, Set<IndexPath>, NSEvent) -> Bool)?
    /// 写入数据到剪切版
    public var pasteboardWriterForItemHandler: ((NSCollectionView, IndexPath) -> NSPasteboardWriting?)?
    /// 拖拽的操作类型
    public var validateDropHandler: ((NSCollectionView, NSDraggingInfo, AutoreleasingUnsafeMutablePointer<NSIndexPath>, UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation)?
    /// 接收拖拽数据
    public var acceptDropHandler: ((NSCollectionView, NSDraggingInfo, IndexPath, NSCollectionView.DropOperation) -> Bool)?
    
    // MARK: - layout
    
    /// item 大小
    public var itemSizeHandler: ((NSCollectionView, IndexPath) -> NSSize)?
    /// 分组 edgeInsets
    public var sectionInsetHandler: ((NSCollectionView, Int) -> NSEdgeInsets)?
    /// 行间距最小值
    public var lineSpacingHandler: ((NSCollectionView, Int) -> CGFloat)?
    /// item间距最小值
    public var itemSpacingHandler: ((NSCollectionView, Int) -> CGFloat)?
    /// header 大小
    public var headerSizeHandler: ((NSCollectionView, Int) -> NSSize)?
    /// footer 大小
    public var footerSizeHandler: ((NSCollectionView, Int) -> NSSize)?
    
    // MARK: - collectionView dataSource
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        numberOfSectionsHandler?(collectionView) ?? 1
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItemsHandler?(collectionView, section) ?? 0
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        itemHandler?(collectionView, indexPath) ?? NSCollectionViewItem()
    }
    
    public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        supplementaryViewHandler?(collectionView, kind, indexPath) ?? NSView()
    }
    
    // MARK: - collectionView delegate
    
    public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        shouldSelectHandler?(collectionView, indexPaths) ?? indexPaths
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        selectHandler?(collectionView, indexPaths)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        shouldDeselectHandler?(collectionView, indexPaths) ?? indexPaths
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        deselectHandler?(collectionView, indexPaths)
    }
    
    // MARK: - collectionView drag
    
    public func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        canDragHandler?(collectionView, indexPaths, event) ?? true
    }
    
    public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> (any NSPasteboardWriting)? {
        pasteboardWriterForItemHandler?(collectionView, indexPath)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: any NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        validateDropHandler?(collectionView, draggingInfo, proposedDropIndexPath, proposedDropOperation) ?? []
    }

    public func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: any NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        acceptDropHandler?(collectionView, draggingInfo, indexPath, dropOperation) ?? false
    }
    
    // MARK: - flow layout
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        if let itemSizeHandler = itemSizeHandler {
            return itemSizeHandler(collectionView, indexPath)
        }
        if collectionViewLayout.isKind(of: NSCollectionViewFlowLayout.self) {
            return (collectionViewLayout as! NSCollectionViewFlowLayout).itemSize
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        if let sectionInsetHandler = sectionInsetHandler {
            return sectionInsetHandler(collectionView, section)
        }
        if collectionViewLayout.isKind(of: NSCollectionViewFlowLayout.self) {
            return (collectionViewLayout as! NSCollectionViewFlowLayout).sectionInset
        }
        return NSEdgeInsetsZero
    }
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let lineSpacingHandler = lineSpacingHandler {
            return lineSpacingHandler(collectionView, section)
        }
        if collectionViewLayout.isKind(of: NSCollectionViewFlowLayout.self) {
            return (collectionViewLayout as! NSCollectionViewFlowLayout).minimumLineSpacing
        }
        return 0
    }
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let itemSpacingHandler = itemSpacingHandler {
            return itemSpacingHandler(collectionView, section)
        }
        if collectionViewLayout.isKind(of: NSCollectionViewFlowLayout.self) {
            return (collectionViewLayout as! NSCollectionViewFlowLayout).minimumInteritemSpacing
        }
        return 0
    }
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        if let headerSizeHandler = headerSizeHandler {
            return headerSizeHandler(collectionView, section)
        }
        if collectionViewLayout.isKind(of: NSCollectionViewFlowLayout.self) {
            return (collectionViewLayout as! NSCollectionViewFlowLayout).headerReferenceSize
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        if let footerSizeHandler = footerSizeHandler {
            return footerSizeHandler(collectionView, section)
        }
        if collectionViewLayout.isKind(of: NSCollectionViewFlowLayout.self) {
            return (collectionViewLayout as! NSCollectionViewFlowLayout).footerReferenceSize
        }
        return .zero
    }
}


// MARK: - 自定义ClipView

fileprivate class YLCollectionClipView: NSClipView {
    override func scrollWheel(with event: NSEvent) {
        guard let collectionView = documentView as? NSCollectionView,
              let layout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout,
              layout.scrollDirection == .horizontal else {
            super.scrollWheel(with: event)
            return
        }

        let delta = abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) ? -event.scrollingDeltaX : -event.scrollingDeltaY
        var bounds = self.bounds
        bounds.origin.x += delta * (event.hasPreciseScrollingDeltas ? 1 : 20)
        self.bounds = bounds
        NotificationCenter.default.post(name: NSScrollView.didLiveScrollNotification, object: superview)
    }
}
