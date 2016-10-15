require 'test_helper'

class MailerTest < ActionMailer::TestCase
  setup do
    @account = accounts(:main)
    @from = "test@curriculr.org"
    @to = "admin@curriculr.org"
    @msg = {
      account: @account.slug,
      contact_email: @from,
      subject: "Testing the emails",
      name: "Jane Smithsonian",
      message: 'Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. 
                Cras justo odio, dapibus ac facilisis in, egestas eget quam. Morbi leo risus, 
                porta ac consectetur ac, vestibulum at eros. Aenean eu leo quam. Pellentesque 
                ornare sem lacinia quam venenatis vestibulum. Curabitur blandit tempus porttitor. 
                Duis mollis, est non commodo luctus, nisi erat porttitor ligula, 
                eget lacinia odio sem nec elit.'
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

  test "password_reset_instructions" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.password_reset_instructions(@user.id, @account.slug, 'iwuikeisoo', from: @from, to: @to).deliver_now
    end
  end

  test "klass_invitation" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.klass_invitation(@account.slug, @from, @to, @klass_3.id, "Tortor Elit Sollicitudin", 'http://localhost/auth/signin').deliver_now
    end
  end

  test "klass_enrollment" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.klass_enrollment(@account.slug, @from, @to, [@klass_1.id, @klass_2.id, @klass_3.id], 'http://localhost/auth/signin').deliver_now
    end
  end

  test "klass_update" do
    body = %(Cras mattis consectetur purus sit amet fermentum. 
            Vestibulum id ligula porta felis euismod semper. Cum sociis 
            natoque penatibus et magnis dis parturient montes, nascetur 
            ridiculus mus. Nullam quis risus eget urna mollis ornare vel eu leo. 
            Maecenas sed diam eget risus varius blandit sit amet non magna.
            
            Vestibulum id ligula porta felis euismod semper. Aenean eu leo quam. 
            Pellentesque ornare sem lacinia quam venenatis vestibulum. Maecenas 
            sed diam eget risus varius blandit sit amet non magna. Etiam porta 
            sem malesuada magna mollis euismod. Curabitur blandit tempus porttitor. 
            Cum sociis natoque penatibus et magnis dis parturient montes, nascetur 
            ridiculus mus.)
    instructors = Course.find_by(:slug => 'stat101').klasses.first.instructors

    body << %(<p>#{Instructor.model_name.human(count: instructors.count) + ': <br>'.html_safe + instructors.map{|i| (i.name || i.user.name)}.join(', ')}</p>).html_safe

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      Mailer.klass_update(@account.slug, @from, @to, 'Sollicitudin Ultricies Ullamcorper Fusce', body, @klass_2.id).deliver_now
    end
  end
end
