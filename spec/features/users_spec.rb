require 'spec_helper'

feature 'Guests' do
  scenario 'can visit front page' do
    visit root_path
    expect(page).to have_text("Open Interactive Education")
  end

  scenario 'can visit blogs page' do
    visit blogs_path
    within 'h2' do
        expect(page).to have_text("Blogs")
    end
  end

  scenario 'can visit klasses page' do
    course = create(:course)
    course.klasses.first.update(approved: true)    
    name = course.name
    visit learn_klasses_path
    expect(current_path).to eq learn_klasses_path
    #save_and_open_page
    expect(page).to have_content(name)
  end

  scenario 'can visit signin page' do
    visit new_user_session_path
    within 'h3' do
        expect(page).to have_content("New Session")
    end
  end

  scenario 'can visit signup page' do
    visit new_user_registration_path
    within 'h3' do
        expect(page).to have_content("New Registration")
    end
  end

  scenario 'can visit about page' do
    visit about_path
    within 'h2' do expect(page).to have_content("about") end
  end

  scenario 'can visit contactus page' do
    visit contactus_path
    expect(page).to have_content("Contact us")
  end

  scenario 'can visit privacy page' do
    visit localized_page_path(:privacy)
    within 'h2' do expect(page).to have_content("privacy") end
  end

  scenario 'can visit terms and conditions page' do
    visit localized_page_path(:terms)
    within 'h2' do expect(page).to have_content("terms") end
  end
end
