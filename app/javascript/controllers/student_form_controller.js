import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "name",
    "email",
    "age",
    "course",
    "city",
    "marks",
    "counter",
    "submit"
  ]

  static values = {
    maxLength: Number
  }

  connect() {
    this.updateCounter()
    this.validateForm()
  }

  updateCounter() {
    const count = this.nameTarget.value.length

    if (this.hasCounterTarget) {
      this.counterTarget.textContent =
        `${count} / ${this.maxLengthValue} characters`
    }

    this.validateForm()
  }

  validateForm() {
    const requiredFields = [
      this.nameTarget,
      this.emailTarget,
      this.ageTarget,
      this.courseTarget,
      this.cityTarget,
      this.marksTarget
    ]

    const formValid = requiredFields.every((field) => {
      return field.value.trim() !== ""
    })

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !formValid
    }
  }
}