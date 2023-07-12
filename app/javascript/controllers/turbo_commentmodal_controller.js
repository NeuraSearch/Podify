import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["commentmodal"]

    hideModal() {
        this.element.parentElement.removeAttribute("src")
        // Remove src reference from parent frame element.
        // Without this, turbo won't re-open the modal on subsequent click
        this.commentmodalTarget.remove()
    }

    submitEnd(e) {
        if (e.detail.success) {
            this.hideModal()
        }
    }

    closeWithKeyboard(e) {
        if (e.code == "Escape") {
            this.hideModal()
        }
    }

    closeBackground(e) {
        if (e && this.commentmodalTarget.contains(e.target)) {
            return
        }
        this.hideModal()
    }
}
