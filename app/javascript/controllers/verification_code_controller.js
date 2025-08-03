import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    format(event) {
        // Remove all non-numeric characters and limit to 6 digits
        let value = event.target.value.replace(/\D/g, '').substring(0, 6)
        event.target.value = value
    }

    preventNonNumeric(event) {
        // Allow: backspace, delete, tab, escape, enter
        if ([8, 9, 13, 27, 46].includes(event.keyCode) ||
            // Allow: Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
            (event.keyCode >= 35 && event.keyCode <= 39) ||
            (event.ctrlKey && [65, 67, 86, 88].includes(event.keyCode))) {
            return
        }
        // Prevent non-numeric input
        if ((event.keyCode < 48 || event.keyCode > 57) &&
            (event.keyCode < 96 || event.keyCode > 105)) {
            event.preventDefault()
        }
    }
}