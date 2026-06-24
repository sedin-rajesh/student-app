# User.create!(
#   email: "admin@example.com",
#   password: "password123",
#   role: :admin
# )

teacher = User.find_or_create_by!(email: "teacher@example.com") do |u|
  u.password = "password123"
  u.role = "teacher"
end

Student.create!([
  {
    name: "Rajesh",
    email: "raj@example.org",
    age: 21,
    course: "Ruby",
    city: "Chennai",
    marks: 92,
    grade: "A",
    user: teacher
  },
  {
    name: "Kumar",
    email: "kumar@example.com",
    age: 22,
    course: "Rails",
    city: "Bangalore",
    marks: 85,
    grade: "B",
    user: teacher
  },
  {
    name: "Priya",
    email: "priya@example.com",
    age: 20,
    course: "React",
    city: "Hyderabad",
    marks: 95,
    grade: "A",
    user: teacher
  },
  {
    name: "Arun",
    email: "arun@example.com",
    age: 23,
    course: "Java",
    city: "Pune",
    marks: 78,
    grade: "C",
    user: teacher
  },
  {
    name: "Divya",
    email: "divya@example.com",
    age: 21,
    course: "Rails",
    city: "Chennai",
    marks: 88,
    grade: "B",
    user: teacher
  }
])
