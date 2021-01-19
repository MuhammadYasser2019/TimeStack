require 'rails_helper'
require 'project_shifts_controller'

RSpec.describe ProjectShiftsController, type: :controller do
  describe "GET #new" do
    it "returns http success" do
      user = FactoryBot.create(:user)
      sign_in user
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #create" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user, email: 'hello@test.com') }
    let!(:shift) { FactoryBot.create(:shift) }
    let(:params) { { project_shift: { shift_supervisor_id: user2.id, shift_id: shift.id, location: 'Milwaukee, WI', capacity: 5 } } }

    #it "redirects to form when end_time is before the start_time" do
    #  user = FactoryBot.create(:user)
    #  sign_in user

    #  post :create, params: bad_params
    #  expect(response).to redirect_to new_shift_path
    #end
    it "returns http success" do
      sign_in user

      post :create, params: params
      project_shift = ProjectShift.first
      expect(project_shift.shift_supervisor_id).to eq(user2.id)
      expect(project_shift.shift_id).to eq(shift.id)
      expect(response).to redirect_to projects_path
    end
  end

  describe "GET #update" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user, email: 'hello@test.com') }
    let!(:shift) { FactoryBot.create(:shift) }
    let!(:shift2) { FactoryBot.create(:shift, name: 'Deer Ranglin') }
    let!(:project_shift) { FactoryBot.create(:project_shift, shift_id: shift.id)}
    let(:params) { { project_shift: { shift_supervisor_id: user2.id, shift_id: shift2.id, location: 'Sparta, VA', capacity: 5 }, id: project_shift.id  } }

    #it "redirects to form when end_time is before the start_time" do
    #  user = FactoryBot.create(:user)
    #  sign_in user

    #  post :create, params: bad_params
    #  expect(response).to redirect_to new_shift_path
    #end
    it "returns http success" do
      sign_in user

      patch :update, params: params
      project_shift = ProjectShift.first
      expect(project_shift.location).to eq('Sparta, VA')
      expect(project_shift.shift_id).to eq(shift2.id)
      expect(response).to redirect_to projects_path
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project_shift) { FactoryBot.create(:project_shift) }
    let(:params) { { project_shift: { id: project_shift.id }, id: project_shift.id } }
    it "deletes the shift and redirects" do
      sign_in user
      delete :destroy, params: params
      expect(ProjectShift.count).to eq(0)
      expect(response).to redirect_to(projects_path)
    end
  end
end