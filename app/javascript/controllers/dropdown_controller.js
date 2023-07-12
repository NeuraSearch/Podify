import Dropdown from "stimulus-dropdown"

// Dropdown controller accessed when clicking the username on the main Podify view.
export default class extends Dropdown {
    connect() {
        super.connect()
    }
    
    toggle(event) {
        super.toggle()
    }
    
    hide(event) {
        super.hide(event)
    }
}
