class Student < ApplicationRecord
    belongs_to :user, counter_cache: true
    has_one_attached :profile_photo
    has_many_attached :documents
    COURSES = %w[Ruby Rails React Java].freeze
    validate :validate_profile_photo
    validate :validate_documents
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

  private
  def validate_profile_photo
    return unless profile_photo.attached?
    unless profile_photo.content_type.in?(%w[image/jpeg image/png image/jpg])
      errors.add(:profile_photo, "must be a JPEG or PNG image")
    end
    if profile_photo.byte_size > 5.megabytes
      errors.add(:profile_photo, "size must be less than 5MB")
    end
  end

  def validate_documents
    documents.each do |document|
      unless document.content_type.in?(%w[application/pdf image/jpeg image/png])
        errors.add(:documents, "must be a PDF or an image (JPEG/PNG)")
      end
      if document.byte_size > 10.megabytes
        errors.add(:documents, "size must be less than 10MB")
      end
    end
  end
end
