import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        // Format any existing value when the controller connects
        if (this.element.value) {
            this.format({ target: this.element })
        }
    }

    format(event) {
        // Remove all non-numeric characters
        let value = event.target.value.replace(/\D/g, '')

        // Limit to 10 digits
        value = value.substring(0, 10)

        // Format the number as (XXX) XXX-XXXX
        let formattedValue = ''
        if (value.length > 0) {
            if (value.length <= 3) {
                formattedValue = `(${value}`
            } else if (value.length <= 6) {
                formattedValue = `(${value.substring(0, 3)}) ${value.substring(3)}`
            } else {
                formattedValue = `(${value.substring(0, 3)}) ${value.substring(3, 6)}-${value.substring(6)}`
            }
        }

        // Update the input value
        event.target.value = formattedValue
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