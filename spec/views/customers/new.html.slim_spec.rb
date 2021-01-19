require 'rails_helper'

RSpec.describe "customers/new", type: :view do
  before(:each) do
    assign(:customer, Customer.new(
      :name => "MyString",
      :address => "MyString",
      :city => "MyString",
      :state => "MyString",
      :zipcode => "MyString"
    ))
  end

  it "renders new customer form" do
    render

    assert_select "form[action=?][method=?]", customers_path, "post" do

      assert_select "input#customer_name[name=?]", "customer[name]"

      assert_select "input#customer_address[name=?]", "customer[address]"

      assert_select "input#customer_city[name=?]", "customer[city]"

      assert_select "input#customer_state[name=?]", "customer[state]"

      assert_select "input#customer_zipcode[name=?]", "customer[zipcode]"
    end
  end
end
