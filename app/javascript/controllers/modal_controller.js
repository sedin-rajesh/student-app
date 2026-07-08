import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["modal"]
  open() {
    this.modalTarget.hidden = false
  }
  close() {
    this.modalTarget.hidden = true
  }
  closeOnBackground(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
  closeOnSuccess(event) {
    if (event.detail.success) {
      this.close()
    }
  }
}