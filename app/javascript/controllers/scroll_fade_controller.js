import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    offset: Number
  }

  connect() {
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener('scroll', this.onScroll)
    this.onScroll()
  }

  disconnect() {
    window.removeEventListener('scroll', this.onScroll)
  }

  onScroll() {
    if (window.scrollY > this.offsetValue) {
      this.element.classList.add('opacity-0', 'pointer-events-none')
      this.element.classList.remove('opacity-100')
    } else {
      this.element.classList.add('opacity-100')
      this.element.classList.remove('opacity-0', 'pointer-events-none')
    }
  }
}