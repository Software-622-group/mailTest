class ApplicationMailer < ActionMailer::Base
  default from: "from@test.com"
  layout 'mailer'
end
