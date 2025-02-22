require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    post users_url, params: {person: {email: "azbshiri@gmail.com", personable_attributes: {password: "secret"}}}
    assert_match "Account was successfully created", flash.notice
  end

  test "it should redirect back when the email address is already in use" do
    email = people(:keith_registered).email
    post users_url, params: {person: {email: email, personable_attributes: {password: "secret"}}}
    assert_response :unprocessable_entity
    assert_match "Email has already been taken", response.body
  end

  test "it should show an error message when the password is blank" do
    email = people(:keith_registered).email
    post users_url, params: {person: {email: email, personable_attributes: {password: ""}}}
    assert_response :unprocessable_entity
    assert_match "password can&#39;t be blank", response.body
  end

  test "it should show an error message when the email is blank" do
    post users_url, params: {person: {email: "", personable_attributes: {password: "secret"}}}
    assert_response :unprocessable_entity
    assert_match "Email can&#39;t be blank", response.body
  end

  test "after create, an account should be bootstrapped and taken to a conversation" do
    email = "fake_email#{rand(1000)}@example.com"
    post users_url, params: {person: {email: email, personable_attributes: {password: "secret"}}}

    user = Person.find_by(email: email).user
    assert_equal 1, user.assistants.count

    assistant = user.assistants.first
    assert_equal 1, assistant.conversations.count

    assert_redirected_to conversation_path(assistant.conversations.first)
  end
end
