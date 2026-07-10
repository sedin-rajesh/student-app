class Student < ApplicationRecord
    belongs_to :user, counter_cache: true
    COURSES = %w[Ruby Rails React Java].freeze
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :age, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :course, presence: true
    validates :city, presence: true
    validates :marks, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

    scope :search, ->(term) {
      return all if term.blank?
      search_term = "%#{sanitize_sql_like(term)}%"
      where(
        "name LIKE :search or email LIKE :search", search: search_term
      )
    }

    scope :by_course, ->(course) {
      course.present? ? where(course: course):all
    }

    scope :search_by_name, ->(name) {
      name.present? ? where("name LIKE ?", "%#{sanitize_sql_like(name)}%") : all
    }

    scope :filter_by_grade, ->(grade) {
      grade.present? ? where(grade: grade) : all
    }

    scope :apply_filter, ->(params) {
      search(params[:search])
      .search_by_name(params[:name])
      .filter_by_grade(params[:grade])
      .by_course(params[:course])
    }

  def result
    marks >= 35 ? "Pass" : "Fail"
  end
end
