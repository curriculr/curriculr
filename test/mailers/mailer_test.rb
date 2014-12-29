require 'test_helper'

class MailerTest < ActionMailer::TestCase
  def setup
    @account = accounts(:main)
    @from = "#{Faker::Lorem.word}@curriculr.org"
    @to = "admin@curriculr.org"
    @msg = {
      account: @account.slug,
      contact_email: @from,
      subject: Faker::Lorem.words(5).join(' '),
      name: Faker::Lorem.words(2).join(' '),
      message: Faker::Lorem.paragraphs(3).join("\n")
    }
    @user = users(:one)
    @klass_1 = klasses(:eng101_sec01)
    @klass_2 = klasses(:eng101_sec02)
    @klass_3 = klasses(:stat101_sec01)
  end

  test "contact_email" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.contactus_email(@from, @to, @msg).deliver_now
    end
  end

  test "confirmation_instructions" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.confirmation_instructions(@user.id, @account.slug, 'xyzhaolwms', from: @from, to: @to).deliver_now
    end
  end

  test "reset_password_instructions" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.reset_password_instructions(@user.id, @account.slug, 'iwuikeisoo', from: @from, to: @to).deliver_now
    end
  end

  test "klass_invitation" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.klass_invitation(@account.slug, @from, @to, @klass_3.id, Faker::Lorem.words(2).join(' '), 'http://localhost/sign_in').deliver_now
    end
  end

  test "klass_enrollment" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.klass_enrollment(@account.slug, @from, @to, [@klass_1.id, @klass_2.id, @klass_3.id], 'http://localhost/sign_in').deliver_now
    end
  end

  test "klass_update" do
    body = Faker::Lorem.paragraphs(3).join("\n")
    instructors = Course.find_by(:slug => 'stat101').klasses.first.instructors

    body << %(<p>#{Instructor.model_name.human(count: instructors.count) + ': <br>'.html_safe + instructors.map{|i| (i.name || i.user.name)}.join(', ')}</p>).html_safe

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.klass_update(@account.slug, @from, @to, Faker::Lorem.words(4).join(' '), body, @klass_2.id).deliver_now
    end
  end
end
