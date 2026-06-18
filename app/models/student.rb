class Student < ApplicationRecord
    belongs_to :user
    COURSES = %w[Ruby Rails React Java].freeze
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :age, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :course, presence: true
    validates :city, presence: true
    validates :marks, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

    scope :search, ->(term) {
      return all if term.blank?
      search_term = "%#{sanitize_sql_like(term)}"
      where(
        "name LIKE :search or email LIKE :search", search: search_term
      )
    }

    scope :by_course, ->(course) {
      course.present? ?where(course: course):all
    }

  def result
    marks >= 35 ? "Pass" : "Fail"
  end
end
