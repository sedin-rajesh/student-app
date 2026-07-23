require "rails_helper"

RSpec.describe "Students (HTML)", type: :request do
  let(:admin)   { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let!(:student) { create(:student, user: teacher) }

  describe "GET /students" do
    context "when authenticated as admin" do
      before { sign_in admin }

      it "lists all students" do
        get students_path
        expect(response).to have_http_status(:ok)
      end

      it "filters students by course" do
        get students_path, params: { course: "Ruby" }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as teacher" do
      before { sign_in teacher }

      it "lists only their own students" do
        get students_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /students/new" do
    before { sign_in teacher }

    it "renders the new form" do
      get new_student_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /students/:id" do
    before { sign_in teacher }

    it "renders the student details" do
      get student_path(student)
      expect(response).to have_http_status(:ok)
    end

    it "renders the student partial for turbo frame request" do
      get student_path(student), headers: { "Turbo-Frame" => "student_frame" }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /students" do
    before { sign_in teacher }

    let(:valid_params) do
      {
        student: {
          name: "HTML Student",
          email: "html.student@example.com",
          age: 21,
          course: "Ruby",
          city: "Mumbai",
          marks: 85
        }
      }
    end

    it "creates a new student and redirects to index" do
      expect {
        post students_path, params: valid_params
      }.to change(Student, :count).by(1)

      expect(response).to redirect_to(students_path)
      expect(flash[:notice]).to eq("Student created successfully.")
    end

    it "renders new form on invalid input" do
      post students_path, params: { student: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /students/:id/edit" do
    before { sign_in teacher }

    it "renders edit form" do
      get edit_student_path(student)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /students/:id" do
    before { sign_in teacher }

    it "updates student attributes and redirects to index" do
      patch student_path(student), params: { student: { name: "Updated HTML Name" } }
      expect(response).to redirect_to(students_path)
      expect(student.reload.name).to eq("Updated HTML Name")
    end

    it "renders edit form on invalid input" do
      patch student_path(student), params: { student: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /students/:id" do
    before { sign_in teacher }

    it "destroys the student and redirects to index" do
      expect {
        delete student_path(student)
      }.to change(Student, :count).by(-1)

      expect(response).to redirect_to(students_path)
      expect(flash[:notice]).to eq("Student deleted successfully")
    end
  end

  describe "POST /students/:id/generate_report_card" do
    before { sign_in teacher }

    it "queues report card job and redirects to show" do
      expect {
        post generate_report_card_student_path(student)
      }.to have_enqueued_job(GenerateReportCardJob).with(student.id)

      expect(response).to redirect_to(student_path(student))
      expect(flash[:notice]).to include("Report card generation has been queued")
    end
  end

  describe "DELETE /students/:id/remove_profile_photo" do
    before { sign_in teacher }

    it "purges the profile photo" do
      student.profile_photo.attach(
        io: StringIO.new("fake image"),
        filename: "test.png",
        content_type: "image/png"
      )

      delete remove_profile_photo_student_path(student)
      expect(response).to redirect_to(students_path)
      expect(student.reload.profile_photo).not_to be_attached
    end
  end

  describe "DELETE /students/:id/remove_document" do
    before { sign_in teacher }

    it "purges the document" do
      student.documents.attach(
        io: StringIO.new("fake doc"),
        filename: "test.pdf",
        content_type: "application/pdf"
      )
      attachment_id = student.documents.first.id

      delete remove_document_student_path(student, attachment_id: attachment_id)
      expect(response).to redirect_to(student_path(student))
      expect(student.reload.documents).not_to be_attached
    end
  end
end
