require 'test_helper'

class PdfConverterControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get convert" do
    get :convert
    assert_response :success
  end

end
