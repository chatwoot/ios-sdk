//
//  KeyboardManager.swift
//  InputBarAccessoryView
//
//  Copyright © 2017-2020 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 8/18/17.
//

import UIKit

/// An object that observes keyboard notifications such that event callbacks can be set for each notification
@available(iOSApplicationExtension, unavailable)
open class KeyboardManager: NSObject, UIGestureRecognizerDelegate {
<<<<<<< HEAD

    /// A callback that passes a `KeyboardNotification` as an input
    public typealias EventCallback = (KeyboardNotification)->Void

    // MARK: - Properties [Public]

    /// A weak reference to a view bounded to the top of the keyboard to act as an `InputAccessoryView`
    /// but kept within the bounds of the `UIViewController`s view
    open weak var inputAccessoryView: UIView?

    /// A flag that indicates if a portion of the keyboard is visible on the screen
    private(set) public var isKeyboardHidden: Bool = true

=======
    
    /// A callback that passes a `KeyboardNotification` as an input
    public typealias EventCallback = (KeyboardNotification)->Void
    
    // MARK: - Properties [Public]
    
    /// A weak reference to a view bounded to the top of the keyboard to act as an `InputAccessoryView`
    /// but kept within the bounds of the `UIViewController`s view
    open weak var inputAccessoryView: UIView?
    
    /// A flag that indicates if a portion of the keyboard is visible on the screen
    private(set) public var isKeyboardHidden: Bool = true
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// A flag that indicates if the additional bottom space should be applied to
    /// the interactive dismissal of the keyboard
    public var shouldApplyAdditionBottomSpaceToInteractiveDismissal: Bool = false

<<<<<<< HEAD
    /// Closure for providing an additional bottom constraint constant for `InputAccessoryView`
    public var additionalInputViewBottomConstraintConstant: () -> CGFloat = { 0 }

    // MARK: - Properties [Private]

=======
    // MARK: - Properties [Private]
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// The additional bottom space specified for laying out the input accessory view
    /// when binding to it
    private var additionalBottomSpace: (() -> CGFloat)?

    /// The `NSLayoutConstraintSet` that holds the `inputAccessoryView` to the bottom if its superview
    private var constraints: NSLayoutConstraintSet?
<<<<<<< HEAD

    /// A weak reference to a `UIScrollView` that has been attached for interactive keyboard dismissal
    private weak var scrollView: UIScrollView?

    /// The `EventCallback` actions for each `KeyboardEvent`. Default value is EMPTY
    private var callbacks: [KeyboardEvent: EventCallback] = [:]

=======
    
    /// A weak reference to a `UIScrollView` that has been attached for interactive keyboard dismissal
    private weak var scrollView: UIScrollView?
    
    /// The `EventCallback` actions for each `KeyboardEvent`. Default value is EMPTY
    private var callbacks: [KeyboardEvent: EventCallback] = [:]
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// The pan gesture that handles dragging on the `scrollView`
    private var panGesture: UIPanGestureRecognizer?

    /// A cached notification used as a starting point when a user dragging the `scrollView` down
    /// to interactively dismiss the keyboard
    private var cachedNotification: KeyboardNotification?
<<<<<<< HEAD

    // MARK: - Initialization

=======
    
    // MARK: - Initialization
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Creates a `KeyboardManager` object an binds the view as fake `InputAccessoryView`
    ///
    /// - Parameter inputAccessoryView: The view to bind to the top of the keyboard but within its superview
    public convenience init(inputAccessoryView: UIView) {
        self.init()
        self.bind(inputAccessoryView: inputAccessoryView)
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Creates a `KeyboardManager` object that observes the state of the keyboard
    public override init() {
        super.init()
        addObservers()
    }
<<<<<<< HEAD

    public required init?(coder: NSCoder) { nil }

    // MARK: - De-Initialization

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Keyboard Observer

=======
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - De-Initialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard Observer
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Add an observer for each keyboard notification
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(notification:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(notification:)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidChangeFrame(notification:)),
                                               name: UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil)
    }
<<<<<<< HEAD

    // MARK: - Mutate Callback Dictionary

=======
    
    // MARK: - Mutate Callback Dictionary
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Sets the `EventCallback` for a `KeyboardEvent`
    ///
    /// - Parameters:
    ///   - event: KeyboardEvent
    ///   - callback: EventCallback
    /// - Returns: Self
    @discardableResult
    open func on(event: KeyboardEvent, do callback: EventCallback?) -> Self {
        callbacks[event] = callback
        return self
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Constrains the `inputAccessoryView` to the bottom of its superview and sets the
    /// `.willChangeFrame` and `.willHide` event callbacks such that it mimics an `InputAccessoryView`
    /// that is bound to the top of the keyboard
    ///
    /// - Parameter inputAccessoryView: The view to bind to the top of the keyboard but within its superview
    /// - Returns: Self
    @discardableResult
    open func bind(inputAccessoryView: UIView, withAdditionalBottomSpace additionalBottomSpace: (() -> CGFloat)? = .none) -> Self {
<<<<<<< HEAD

=======
        
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
        guard let superview = inputAccessoryView.superview else {
            fatalError("`inputAccessoryView` must have a superview")
        }
        self.inputAccessoryView = inputAccessoryView
        self.additionalBottomSpace = additionalBottomSpace
        inputAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        constraints = NSLayoutConstraintSet(
<<<<<<< HEAD
            bottom: inputAccessoryView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: additionalInputViewBottomConstraintConstant()),
=======
            bottom: inputAccessoryView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
            left: inputAccessoryView.leftAnchor.constraint(equalTo: superview.leftAnchor),
            right: inputAccessoryView.rightAnchor.constraint(equalTo: superview.rightAnchor)
        ).activate()

        callbacks[.willShow] = { [weak self] (notification) in
<<<<<<< HEAD
            guard
                self?.isKeyboardHidden == false,
                self?.constraints?.bottom?.constant == self?.additionalInputViewBottomConstraintConstant(),
                notification.isForCurrentApp
            else { return }

            let keyboardHeight = notification.endFrame.height
=======
            let keyboardHeight = notification.endFrame.height
            guard
                self?.isKeyboardHidden == false,
                self?.constraints?.bottom?.constant == 0,
                notification.isForCurrentApp else { return }
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
            self?.animateAlongside(notification) {
                self?.constraints?.bottom?.constant = -keyboardHeight - (additionalBottomSpace?() ?? 0)
                self?.inputAccessoryView?.superview?.layoutIfNeeded()
            }
        }
        callbacks[.willChangeFrame] = { [weak self] (notification) in
            let keyboardHeight = notification.endFrame.height
            guard
                self?.isKeyboardHidden == false,
<<<<<<< HEAD
                notification.isForCurrentApp
            else { return }

=======
                notification.isForCurrentApp else { return }
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
            self?.animateAlongside(notification) {
                self?.constraints?.bottom?.constant = -keyboardHeight - (additionalBottomSpace?() ?? 0)
                self?.inputAccessoryView?.superview?.layoutIfNeeded()
            }
        }
        callbacks[.willHide] = { [weak self] (notification) in
            guard notification.isForCurrentApp else { return }
            self?.animateAlongside(notification) { [weak self] in
<<<<<<< HEAD
                self?.constraints?.bottom?.constant = self?.additionalInputViewBottomConstraintConstant() ?? 0
=======
                self?.constraints?.bottom?.constant = 0
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
                self?.inputAccessoryView?.superview?.layoutIfNeeded()
            }
        }
        return self
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Adds a `UIPanGestureRecognizer` to the `scrollView` to enable interactive dismissal`
    ///
    /// - Parameter scrollView: UIScrollView
    /// - Returns: Self
    @discardableResult
    open func bind(to scrollView: UIScrollView) -> Self {
        self.scrollView = scrollView
        self.scrollView?.keyboardDismissMode = .interactive // allows dismissing keyboard interactively
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer))
        recognizer.delegate = self
        self.panGesture = recognizer
        self.scrollView?.addGestureRecognizer(recognizer)
        return self
    }
<<<<<<< HEAD

    // MARK: - Keyboard Notifications

=======
    
    // MARK: - Keyboard Notifications
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// An observer method called last in the lifecycle of a keyboard becoming visible
    ///
    /// - Parameter notification: NSNotification
    @objc
    open func keyboardDidShow(notification: NSNotification) {
        guard let keyboardNotification = KeyboardNotification(from: notification) else { return }
        callbacks[.didShow]?(keyboardNotification)
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// An observer method called last in the lifecycle of a keyboard becoming hidden
    ///
    /// - Parameter notification: NSNotification
    @objc
    open func keyboardDidHide(notification: NSNotification) {
        isKeyboardHidden = true
        guard let keyboardNotification = KeyboardNotification(from: notification) else { return }
        callbacks[.didHide]?(keyboardNotification)
        cachedNotification = nil
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// An observer method called third in the lifecycle of a keyboard becoming visible/hidden
    ///
    /// - Parameter notification: NSNotification
    @objc
    open func keyboardDidChangeFrame(notification: NSNotification) {
        guard let keyboardNotification = KeyboardNotification(from: notification) else { return }
        callbacks[.didChangeFrame]?(keyboardNotification)
        cachedNotification = keyboardNotification
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// An observer method called first in the lifecycle of a keyboard becoming visible/hidden
    ///
    /// - Parameter notification: NSNotification
    @objc
    open func keyboardWillChangeFrame(notification: NSNotification) {
        guard let keyboardNotification = KeyboardNotification(from: notification) else { return }
        callbacks[.willChangeFrame]?(keyboardNotification)
        cachedNotification = keyboardNotification
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// An observer method called second in the lifecycle of a keyboard becoming visible
    ///
    /// - Parameter notification: NSNotification
    @objc
    open func keyboardWillShow(notification: NSNotification) {
        isKeyboardHidden = false
        guard let keyboardNotification = KeyboardNotification(from: notification) else { return }
        callbacks[.willShow]?(keyboardNotification)
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// An observer method called second in the lifecycle of a keyboard becoming hidden
    ///
    /// - Parameter notification: NSNotification
    @objc
    open func keyboardWillHide(notification: NSNotification) {
        guard let keyboardNotification = KeyboardNotification(from: notification) else { return }
        callbacks[.willHide]?(keyboardNotification)
        cachedNotification = nil
    }
<<<<<<< HEAD

    // MARK: - Helper Methods

    private func animateAlongside(_ notification: KeyboardNotification, animations: @escaping ()->Void) {
        UIView.animate(withDuration: notification.timeInterval, delay: 0, options: [notification.animationOptions, .allowAnimatedContent, .beginFromCurrentState], animations: animations, completion: nil)
    }

    // MARK: - UIGestureRecognizerDelegate

=======
    
    // MARK: - Helper Methods
    
    private func animateAlongside(_ notification: KeyboardNotification, animations: @escaping ()->Void) {
        UIView.animate(withDuration: notification.timeInterval, delay: 0, options: [notification.animationOptions, .allowAnimatedContent, .beginFromCurrentState], animations: animations, completion: nil)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Starts with the cached `KeyboardNotification` and calculates a new `endFrame` based
    /// on the `UIPanGestureRecognizer` then calls the `.willChangeFrame` `EventCallback` action
    ///
    /// - Parameter recognizer: UIPanGestureRecognizer
    @objc
    open func handlePanGestureRecognizer(recognizer: UIPanGestureRecognizer) {
        guard
            var keyboardNotification = cachedNotification,
            case .changed = recognizer.state,
            let view = recognizer.view,
            let window = UIApplication.shared.windows.first
<<<<<<< HEAD
        else { return }

        guard
            // if there's no difference in frames for the `cachedNotification`, no adjustment is necessary.
            // This is true when the keyboard is completely dismissed, or our pan doesn't intersect below the keyboard
            keyboardNotification.startFrame != keyboardNotification.endFrame,
            // when the width of the keyboard from endFrame is smaller than the width of scrollView manager is tracking
            // with panGesture, we can assume the keyboard is floatig ahd updating inputAccessoryView is not necessary
            keyboardNotification.endFrame.width >= view.frame.width
        else {
            return
        }

=======
            else { return }

        // if there's no difference in frames for the `cachedNotification`, no adjustment is necessary. This is true when the keyboard is completely dismissed, or our pan doesn't intersect below the keyboard
        guard cachedNotification?.startFrame != cachedNotification?.endFrame else { return }
        
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
        let location = recognizer.location(in: view)
        let absoluteLocation = view.convert(location, to: window)
        var frame = keyboardNotification.endFrame
        frame.origin.y = max(absoluteLocation.y, window.bounds.height - frame.height)
        frame.size.height = window.bounds.height - frame.origin.y
        keyboardNotification.endFrame = frame

        var yCoordinateDirectlyAboveKeyboard = -frame.height
<<<<<<< HEAD
        if shouldApplyAdditionBottomSpaceToInteractiveDismissal, let additionalBottomSpace = additionalBottomSpace {
=======

        if shouldApplyAdditionBottomSpaceToInteractiveDismissal,
           let additionalBottomSpace = additionalBottomSpace {
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
            yCoordinateDirectlyAboveKeyboard -= additionalBottomSpace()
        }

        /// If a tab bar is shown, letting this number becoming > 0 makes it so the accessoryview disappears below the tab bar. setting the max value to 0 prevents that
<<<<<<< HEAD
        let aboveKeyboardAndAboveTabBar = min(additionalInputViewBottomConstraintConstant(), yCoordinateDirectlyAboveKeyboard)
        self.constraints?.bottom?.constant = aboveKeyboardAndAboveTabBar
        self.inputAccessoryView?.superview?.layoutIfNeeded()
    }

=======
        let aboveKeyboardAndAboveTabBar = min(0, yCoordinateDirectlyAboveKeyboard)
        self.constraints?.bottom?.constant = aboveKeyboardAndAboveTabBar
        self.inputAccessoryView?.superview?.layoutIfNeeded()
    }
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Only receive a `UITouch` event when the `scrollView`'s keyboard dismiss mode is interactive
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return scrollView?.keyboardDismissMode == .interactive
    }
<<<<<<< HEAD

=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
    /// Only recognice simultaneous gestures when its the `panGesture`
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer === panGesture
    }
<<<<<<< HEAD
=======
    
>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
}
