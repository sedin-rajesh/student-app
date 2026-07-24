class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", ENV.fetch("SMTP_USERNAME", "noreply@example.com"))
  layout "mailer"
end
