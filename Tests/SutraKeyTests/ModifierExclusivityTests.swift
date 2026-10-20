import AppKit
import Testing
@testable import SutraKey

@Suite("ModifierExclusivityTests")
struct ModifierExclusivityTests {

    @Test("Shift only returns true")
    func testShiftOnlyReturnsTrue() {
        let flags: NSEvent.ModifierFlags = [.shift]
        #expect(ModifierExclusivityValidator.isShiftOnly(flags: flags) == true)
    }

    @Test("Shift plus Command returns false")
    func testShiftPlusCommandReturnsFalse() {
        let flags: NSEvent.ModifierFlags = [.shift, .command]
        #expect(ModifierExclusivityValidator.isShiftOnly(flags: flags) == false)
    }

    @Test("Shift plus Option returns false")
    func testShiftPlusOptionReturnsFalse() {
        let flags: NSEvent.ModifierFlags = [.shift, .option]
        #expect(ModifierExclusivityValidator.isShiftOnly(flags: flags) == false)
    }

    @Test("Shift plus Control or CapsLock returns false")
    func testShiftPlusControlOrCapsLockReturnsFalse() {
        let flagsCtrl: NSEvent.ModifierFlags = [.shift, .control]
        let flagsCaps: NSEvent.ModifierFlags = [.shift, .capsLock]
        #expect(ModifierExclusivityValidator.isShiftOnly(flags: flagsCtrl) == false)
        #expect(ModifierExclusivityValidator.isShiftOnly(flags: flagsCaps) == false)
    }

    @Test("No modifiers returns false")
    func testNoModifiersReturnsFalse() {
        let flags: NSEvent.ModifierFlags = []
        #expect(ModifierExclusivityValidator.isShiftOnly(flags: flags) == false)
    }
}
