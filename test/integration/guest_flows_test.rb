require 'test_helper'

class GuestFlowsTest < ActionDispatch::IntegrationTest
  def setup
    [accounts(:main), accounts(:secondary)].each do |a|
      I18n.t('config.auto_generated_pages').each do |slug, name|
        $site['supported_locales'].keys.each do |locale|
          page = Page.create(
            :name => name,
            :about => I18n.t("page.text.under_construction"),
            :public => true,
            :published => true,
            :owner => a.user,
            :slug => "#{slug}-#{locale}",
            :account => a
          )
        end
      end
    end
  end

  test 'can visit front page' do
    visit root_path

    assert page.has_text?("Open and Interactive Learning")
    `pg_dump -a -T schema_migrations curriculr_test > #{Rails.root}/db/backup_fixtures.sql`
  end

  test 'can visit blogs page' do
    visit blogs_path
    within 'h2' do
      assert page.has_content?("Official Blog")
    end
  end

  test 'can visit klasses page' do
    visit learn_klasses_path

    assert page.has_content?(klasses(:stat101_sec01).course.name)
  end

  test 'can visit signin page' do
    visit new_user_session_path

    assert_text("Sign in")
  end

  test 'can visit signup page' do
    visit new_user_registration_path

    assert_text("By signing up for a new account, you are agreeing to")
  end

  test 'can visit about page' do
    visit about_path

    assert page.has_content?("About")
  end

  test 'can visit contactus page' do
    visit contactus_path

    assert page.has_content?("Contact us")
  end

  test 'can visit privacy page' do
    visit localized_page_path(:privacy)

    assert page.has_content?("Privacy")
  end

  test 'can visit terms and conditions page' do
    visit localized_page_path(:terms)

    assert page.has_content?("Terms of service")
  end

  test 'can register with a name, email and password' do
    visit new_user_registration_path

    fill_in "user_name",                 :with => "John Smith "
    fill_in "user_email",                 :with => "jsmith@example.com"
    fill_in "user_password",              :with => "a_secret"
    fill_in "user_password_confirmation", :with => "a_secret"

    click_button "Create an account"

    assert page.html.include?("A message with a confirmation link has been sent to your email address.")
    assert_equal root_path, current_path
  end

  test 'can sign in as a student' do
    user = users(:two)
    visit new_user_session_path

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'

    click_button 'Sign in'

    assert page.has_content?(user.name)
    assert_equal home_path, current_path

    logout(:user)
  end

  test 'can sign in as an instructor' do
    instructor = users(:assistant)
    visit new_user_session_path

    fill_in 'user_email', with: instructor.email
    fill_in 'user_password', with: 'password'

    click_button 'Sign in'

    assert page.has_content?("Teach")
    assert_equal home_path, current_path

    logout(:user)
  end

  test 'can sign in as an admin' do
    admin = users(:super)
    visit new_user_session_path
    fill_in 'user_email', with: admin.email
    fill_in 'user_password', with: 'password'

    click_button 'Sign in'

    assert page.has_content?("Administration")
    assert_equal home_path, current_path

    logout(:user)
  end

  test 'can sign out' do
    user = users(:one)
    login_as(user, :scope => :user)
    visit home_path

    click_link "Sign out"
    assert_equal root_path, current_path
  end
end
