require 'test_helper'

class AdminFlowsTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:super)
    login_as(@admin, :scope => :user)
    visit home_path
  end

  def teardown
    logout(:user)
  end

  test 'can list users' do
    find(:xpath, "//a[@href='/users']").click

    find(:xpath, "//a[@href='/users/#{@admin.id}/edit']").click

    fill_in 'Name', with: 'Mighty Admin'

    click_button 'Update'

    assert_equal 'Mighty Admin', User.find(@admin.id).name
  end

  test 'can add a new user' do
    find(:xpath, "//a[@href='/users']").click

    click_link 'New'
    email = Faker::Lorem.word + "@bar.foo"
    fill_in 'Name', with: Faker::Lorem.words(2).join(' ')
    fill_in 'Email', with: email
    fill_in 'Password', with: 'a_secret'
    fill_in 'Confirm Password', with: 'a_secret'

    click_button 'Create'

    assert page.has_content?(email)
  end

  test 'can grant user a faculty role' do
    instructor = users(:one)

    find(:xpath, "//a[@href='/users']").click

    find(:xpath, "//a[@href='/users/#{instructor.id}?opr=faculty']").click

    assert instructor.has_role?(:faculty)
  end

  test 'can create an announcement' do
    find(:xpath, "//a[@href='/admin/announcements']").click

    click_link 'New'
    message = Faker::Lorem.words(5).join(" ")
    fill_in 'announcement_message', with: message
    fill_in 'announcement_starts_at', with: Time.zone.today
    fill_in 'announcement_ends_at', with: 20.days.from_now

    click_button 'Create'

    assert page.has_content?(message)
  end

  test 'can edit an announcement' do
    announcement = announcements(:maintenance)

    find(:xpath, "//a[@href='/admin/announcements']").click

    find(:xpath, "//a[@href='/admin/announcements/#{announcement.id}/edit']").click

    message = Faker::Lorem.words(4).join(" ")
    fill_in 'announcement_message', with: message

    click_button 'Update'

    assert page.has_content?(message)
  end

  # test 'can remove an announcement' do
  #   announcement = announcements(:maintenance)

  #   find(:xpath, "//a[@href='/admin/announcements']").click
  #   find(:xpath, "//a[@href='/admin/announcements/#{announcement.id}']").click

  #   #save_and_open_page
  # end

  test 'can visit dashboard' do
    assert page.has_content?('Dashboard')
  end

  test 'can create a page' do
    find(:xpath, "//a[@href='/pages']").click

    click_link 'New'
    title = Faker::Lorem.words(2).join(' ')
    fill_in 'page_name', with: title
    fill_in 'wmd-inputabout', with: Faker::Lorem.paragraphs(3).join("\n")
    fill_in 'page_slug', with: Faker::Lorem.word

    click_button 'Create'

    assert page.has_content?(title)
  end

  test 'can edit a page' do
    blog = pages(:blog_post)

    find(:xpath, "//a[@href='/pages']").click
    find(:xpath, "//a[@href='/pages/#{blog.slug}/edit']").click

    fill_in 'page_name', with: 'Blog one'
    click_button 'Update'

    assert page.has_content?('Blog one')
  end
end
