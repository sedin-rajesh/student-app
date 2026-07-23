FactoryBot.define do
  factory :student do
    sequence(:name)  { |n| "Student #{n}" }
    sequence(:email) { |n| "student#{n}@example.com" }
    age    { 20 }
    course { "Ruby" }
    city   { "Mumbai" }
    marks  { 75 }
    grade  { "A" }
    association :user, factory: [ :user, :teacher ]

    trait :passing do
      marks { 80 }
    end

    trait :failing do
      marks { 20 }
    end

    trait :rails_course do
      course { "Rails" }
    end

    trait :react_course do
      course { "React" }
    end

    trait :java_course do
      course { "Java" }
    end

    trait :grade_a do
      grade { "A" }
      marks { 90 }
    end

    trait :grade_b do
      grade { "B" }
      marks { 70 }
    end

    trait :grade_c do
      grade { "C" }
      marks { 50 }
    end
  end
end
