require "rails_helper"

RSpec.describe "Api::V1::Students", type: :request do
  let(:admin)   { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }

  let(:admin_headers)   { auth_headers_for(admin) }
  let(:teacher_headers) { auth_headers_for(teacher) }

  describe "GET /api/v1/students" do
    context "when authenticated as admin" do
      let!(:teacher2)  { create(:user, :teacher) }
      let!(:student1)  { create(:student, user: teacher2) }
      let!(:student2)  { create(:student, user: teacher2) }

      it "returns all students with status 200" do
        get api_v1_students_path, headers: admin_headers, as: :json

        expect(response).to have_http_status(:ok)
        ids = response.parsed_body.map { |s| s["id"] }
        expect(ids).to contain_exactly(student1.id, student2.id)
      end
    end

    context "when authenticated as teacher" do
      let!(:my_student)    { create(:student, user: teacher) }
      let!(:other_student) { create(:student) }

      it "returns only own students with status 200" do
        get api_v1_students_path, headers: teacher_headers, as: :json

        expect(response).to have_http_status(:ok)
        ids = response.parsed_body.map { |s| s["id"] }
        expect(ids).to contain_exactly(my_student.id)
      end
    end

    context "with search filter" do
      let!(:alice) { create(:student, name: "Alice", user: admin) }
      let!(:bob)   { create(:student, name: "Bob",   user: admin) }

      it "returns students matching the search term" do
        get api_v1_students_path, headers: admin_headers,
            params: { search: "Alice" }, as: :json

        expect(response).to have_http_status(:ok)
        names = response.parsed_body.map { |s| s["name"] }
        expect(names).to contain_exactly("Alice")
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        get api_v1_students_path, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/students/:id" do
    context "when admin requests any student" do
      let(:student) { create(:student) }

      it "returns the student with status 200" do
        get api_v1_student_path(student), headers: admin_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["id"]).to eq(student.id)
      end
    end

    context "when teacher requests their own student" do
      let(:student) { create(:student, user: teacher) }

      it "returns the student with status 200" do
        get api_v1_student_path(student), headers: teacher_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["id"]).to eq(student.id)
      end
    end

    context "when teacher requests another teacher's student" do
      let(:other_student) { create(:student) }

      it "returns 404 Not Found" do
        get api_v1_student_path(other_student), headers: teacher_headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when student id does not exist" do
      it "returns 404 Not Found" do
        get api_v1_student_path(id: 999_999), headers: admin_headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/students" do
    let(:valid_attributes) do
      {
        student: {
          name:   "New Student",
          email:  "new.student@example.com",
          age:    22,
          course: "Ruby",
          city:   "Delhi",
          marks:  80
        }
      }
    end

    context "when admin creates a student" do
      it "creates a student and returns 201" do
        admin_headers
        expect do
          post api_v1_students_path,
               headers: admin_headers,
               params:  valid_attributes.deep_merge(student: { user_id: teacher.id }),
               as: :json
        end.to change(Student, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.parsed_body["email"]).to eq("new.student@example.com")
      end

      it "enqueues a notification email" do
        expect do
          post api_v1_students_path,
               headers: admin_headers,
               params:  valid_attributes.deep_merge(student: { user_id: teacher.id }),
               as: :json
        end.to have_enqueued_mail(NotificationMailer, :student_created)
      end
    end

    context "when teacher creates a student" do
      it "creates a student assigned to that teacher" do
        post api_v1_students_path,
             headers: teacher_headers,
             params:  valid_attributes,
             as: :json

        expect(response).to have_http_status(:created)
        created_student = Student.find(response.parsed_body["id"])
        expect(created_student.user).to eq(teacher)
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) do
        { student: { name: "", email: "bad-email", age: -1, course: "", city: "", marks: 200 } }
      end

      it "returns 422 Unprocessable Entity" do
        post api_v1_students_path,
             headers: admin_headers,
             params:  invalid_attributes,
             as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to have_key("errors")
      end

      it "does not create a student record" do
        expect do
          post api_v1_students_path,
               headers: admin_headers,
               params:  invalid_attributes,
               as: :json
        end.not_to change(Student, :count)
      end
    end

    context "without authentication" do
      it "returns 401 Unauthorized" do
        post api_v1_students_path, params: valid_attributes, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/v1/students/:id" do
    context "when admin updates a student" do
      let(:student) { create(:student) }

      it "updates the student and returns 200" do
        patch api_v1_student_path(student),
              headers: admin_headers,
              params:  { student: { name: "Updated Name" } },
              as: :json

        expect(response).to have_http_status(:ok)
        expect(student.reload.name).to eq("Updated Name")
      end
    end

    context "when teacher updates their own student" do
      let(:student) { create(:student, user: teacher) }

      it "updates the student and returns 200" do
        patch api_v1_student_path(student),
              headers: teacher_headers,
              params:  { student: { city: "Pune" } },
              as: :json

        expect(response).to have_http_status(:ok)
        expect(student.reload.city).to eq("Pune")
      end
    end

    context "when marks are updated" do
      let(:student) { create(:student) }

      it "enqueues a marks_posted notification" do
        admin_headers
        expect do
          patch api_v1_student_path(student),
                headers: admin_headers,
                params:  { student: { marks: 95 } },
                as: :json
        end.to have_enqueued_mail(NotificationMailer, :marks_posted)
      end
    end

    context "with invalid attributes" do
      let(:student) { create(:student) }

      it "returns 422 with validation errors" do
        patch api_v1_student_path(student),
              headers: admin_headers,
              params:  { student: { email: "invalid" } },
              as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when teacher tries to update another teacher's student" do
      let(:other_student) { create(:student) }

      it "returns 404 Not Found" do
        patch api_v1_student_path(other_student),
              headers: teacher_headers,
              params:  { student: { city: "Chennai" } },
              as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /api/v1/students/:id" do
    context "when admin deletes a student" do
      let!(:student) { create(:student) }

      it "deletes the student and returns 204" do
        expect do
          delete api_v1_student_path(student), headers: admin_headers, as: :json
        end.to change(Student, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when teacher deletes their own student" do
      let!(:student) { create(:student, user: teacher) }

      it "deletes the student and returns 204" do
        expect do
          delete api_v1_student_path(student), headers: teacher_headers, as: :json
        end.to change(Student, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when teacher tries to delete another teacher's student" do
      let!(:other_student) { create(:student) }

      it "returns 404 and does not delete" do
        expect do
          delete api_v1_student_path(other_student), headers: teacher_headers, as: :json
        end.not_to change(Student, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "without authentication" do
      let!(:student) { create(:student) }

      it "returns 401 and does not delete" do
        expect do
          delete api_v1_student_path(student), as: :json
        end.not_to change(Student, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
