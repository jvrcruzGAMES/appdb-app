import UIKit

/// Row or Accessory selection callback.
public typealias Selection = (StaticRow) -> Void
public typealias ValueChange = (Bool) -> ()

/// Row copy callback
public typealias CopyAction = (StaticRow) -> Void

/// Representation of a table row.
public struct StaticRow: Hashable, Equatable {

    // MARK: - Types

    /// Representation of a row accessory.
    public enum Accessory: Equatable {
        /// No accessory
        case none

        /// Chevron
        case disclosureIndicator

        /// Info button with chevron. Handles selection.
        case detailDisclosureButton(Selection)

        /// Checkmark
        case checkmark

        /// Checkmark Placeholder.
        /// Allows spacing to continue to work when switching back & forth between checked states.
        case checkmarkPlaceholder

        /// Info button. Handles selection.
        case detailButton(Selection)
        
        /// Switch. Handles value change.
        case switchToggle(value: Bool, ValueChange)

        /// Custom view
        case view(UIView)

        /// Table view cell accessory type
        public var type: UITableViewCell.AccessoryType {
            switch self {
            case .disclosureIndicator: return .disclosureIndicator
            case .detailDisclosureButton(_): return .detailDisclosureButton
            case .checkmark: return .checkmark
            case .detailButton(_): return .detailButton
            default: return .none
            }
        }

        /// Accessory view
        public var view: UIView? {
            switch self {
            case .view(let view): return view
            case .switchToggle(let value, let valueChange):
                return SwitchAccessory(initialValue: value, valueChange: valueChange)
            case .checkmarkPlaceholder:
                return UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            default: return nil
            }
        }

        /// Selection block for accessory buttons
        public var selection: Selection? {
            switch self {
            case .detailDisclosureButton(let selection): return selection
            case .detailButton(let selection): return selection
            default: return nil
            }
        }
    }

    public typealias Context = [String: Any]

    /// Representation of an editing action, when swiping to edit a cell.
    public struct EditAction {
        /// Title of the action's button.
        public let title: String
        
        /// Styling for button's action, used primarily for destructive actions.
        public let style: UITableViewRowAction.Style
        
        /// Background color of the button.
        public let backgroundColor: UIColor?
        
        /// Visual effect to be applied to the button's background.
        public let backgroundEffect: UIVisualEffect?
        
        /// Invoked when selecting the action.
        public let selection: (() -> Void)?
        
        public init(title: String, style: UITableViewRowAction.Style = .default, backgroundColor: UIColor? = nil, backgroundEffect: UIVisualEffect? = nil, selection: (() -> Void)? = nil) {
            self.title = title
            self.style = style
            self.backgroundColor = backgroundColor
            self.backgroundEffect = backgroundEffect
            self.selection = selection
        }
    }

    // MARK: - Properties

    /// Unique identifier for the row.
    public let uuid: String

    /// The row's primary text.
    public var text: String?

    /// The row's secondary text.
    public var detailText: String?

    /// Accessory for the row.
    public var accessory: Accessory

    /// Image for the row
    public var image: UIImage?

    /// Action to run when the row is selected.
    public var selection: Selection?

    /// View to be used for the row.
    public var cellClass: Cell.Type

    /// Additional information for the row.
    public var context: Context?
    
    /// Actions to show when swiping the cell, such as Delete.
    public var editActions: [EditAction]
    
    /// Action to run when the row is selected to copy
    public var copyAction: CopyAction?

    var canCopy: Bool {
        return copyAction != nil
    }
    
    var canEdit: Bool {
        return editActions.count > 0
    }

    var isSelectable: Bool {
        return selection != nil
    }

    var cellIdentifier: String {
        return cellClass.description()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }


    // MARK: - Initializers

    public init(text: String? = nil, detailText: String? = nil, selection: Selection? = nil, image: UIImage? = nil, accessory: Accessory = .none, cellClass: Cell.Type? = nil, context: Context? = nil, editActions: [EditAction] = [], copyAction: CopyAction? = nil, uuid: String = UUID().uuidString) {
        self.uuid = uuid
        self.text = text
        self.detailText = detailText
        self.selection = selection
        self.image = image
        self.accessory = accessory
        self.cellClass = cellClass ?? Value1Cell.self
        self.context = context
        self.editActions = editActions
        self.copyAction = copyAction
    }
}


public func ==(lhs: StaticRow, rhs: StaticRow) -> Bool {
    return lhs.uuid == rhs.uuid
}


public func ==(lhs: StaticRow.Accessory, rhs: StaticRow.Accessory) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.disclosureIndicator, .disclosureIndicator): return true
    case (.detailDisclosureButton(_), .detailDisclosureButton(_)): return true
    case (.checkmark, .checkmark): return true
    case (.detailButton(_), .detailButton(_)): return true
    case (.view(let l), .view(let r)): return l == r
    default: return false
    }
}
