require 'rails_helper'
require 'employment_types_controller'

RSpec.describe EmploymentTypesController, type: :controller do

  describe "GET #new" do
    it "returns http success" do
      user = FactoryBot.create(:user)
      sign_in user
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #create" do

    it "returns http success" do
      user =FactoryBot.create(:user) 
      employment_type = FactoryBot.create(:employment_type)
      sign_in user
      
      post :create, params: { employment_type: { name: "tom", customer_id: 1} }
      expect(response).to redirect_to customers_path
    end
  end


  describe "GET #update" do
    it "returns http success" do
      user = FactoryBot.create(:user) 
      employment_type = FactoryBot.create(:employment_type)
      sign_in user
      patch :update
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #destroy" do
    it "returns http success" do
      get :destroy
      expect(response).to have_http_status(:success)
    end
  end

end
