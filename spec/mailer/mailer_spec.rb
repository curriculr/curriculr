if false
require 'faker'

account = Account.find(1)
from = "#{Faker::Lorem.word}@duroosi.com"
to = "aalgahmi@duroosi.com"
msg = {
	account: account.slug,
	contact_email: from,
	subject: Faker::Lorem.words(5).join(' '),
	name: Faker::Lorem.words(2).join(' '),
	message: Faker::Lorem.paragraphs(3).join("\n")
}

Mailer.contactus_email(from, to, msg).deliver_now

Mailer.confirmation_instructions(1, account.slug, 'xyzhaolwms', from: from, to: to).deliver_now

Mailer.reset_password_instructions(1, account.slug, 'iwuikeisoo', from: from, to: to).deliver_now
 
Mailer.klass_invitation(account.slug, from, to, 19, Faker::Lorem.words(2).join(' '), 'http://localhost/sign_in').deliver_now

Mailer.klass_enrollment(account.slug, from, to, [19,20,21], 'http://localhost/sign_in').deliver_now


body = Faker::Lorem.paragraphs(3).join("\n")
instructors = Klass.find(2).instructors

body << %(<p>#{Instructor.model_name.human(count: instructors.count) + ': <br>'.html_safe + instructors.map{|i| (i.name || i.user.name)}.join(', ')}</p>).html_safe

Mailer.klass_update(account.slug, from, to, Faker::Lorem.words(4).join(' '), body, 20).deliver_now

end