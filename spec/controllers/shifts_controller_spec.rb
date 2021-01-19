require 'rails_helper'
require 'shifts_controller'

RSpec.describe ShiftsController, type: :controller do
  describe "GET #new" do
    it "returns http success" do
      user = FactoryBot.create(:user)
      sign_in user
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #create" do
    let(:params) { { shift: { name: 'New Shift' }, start_time_hour: '9', start_time_minute: '00', start_time_period: 'AM', end_time_hour: '5', end_time_minute: '00', end_time_period: 'PM' } }
    let(:bad_params) { { shift: { name: 'New Shift' }, start_time_hour: '9', start_time_minute: '00', start_time_period: 'AM', end_time_hour: '5', end_time_minute: '00', end_time_period: 'AM' } }

    #it "redirects to form when end_time is before the start_time" do
    #  user = FactoryBot.create(:user)
    #  sign_in user

    #  post :create, params: bad_params
    #  expect(response).to redirect_to new_shift_path
    #end
    it "returns http success" do
      user = FactoryBot.create(:user)
      sign_in user

      post :create, params: params
      expect(Shift.last.start_time).to eq('9:00 AM')
      expect(Shift.last.end_time).to eq('5:00 PM')
      expect(response).to redirect_to customers_path
    end
  end


  describe "GET #update" do
    let(:shift) { FactoryBot.create(:shift) }
    let(:params) { { shift: { name: 'New Name' }, id: shift.id, regular_hours: 8.0, start_time_hour: '9', start_time_minute: '00', start_time_period: 'AM', end_time_hour: '5', end_time_minute: '00', end_time_period: 'PM' } }
    let(:bad_params) { { shift: { name: 'New Shift' }, id: shift.id, regular_hours: 8.0, start_time_hour: '9', start_time_minute: '00', start_time_period: 'AM', end_time_hour: '5', end_time_minute: '00', end_time_period: 'AM' } }

    it "redirects to form when end_time is before the start_time" do
      user = FactoryBot.create(:user)
      sign_in user

      patch :update, params: bad_params
      expect(response).to redirect_to edit_shift_path(shift.id)
    end

    it "updates the shift and redirects" do
      user = FactoryBot.create(:user)
      sign_in user
      patch :update, params: params
      expect(Shift.find(shift.id).name).to eq('New Name')
      expect(Shift.last.start_time).to eq('9:00 AM')
      expect(Shift.last.end_time).to eq('5:00 PM')
      expect(response).to redirect_to(customers_path)
    end
  end

  describe "DELETE #destroy" do
    let!(:shift) { FactoryBot.create(:shift, default: true, customer_id: 1) }
    let!(:other_shift) { FactoryBot.create(:shift, name: 'Beeg Boi', default: false, customer_id: 1) }
    let(:params) { { shift: { name: 'New Name', id: shift.id }, id: shift.id, regular_hours: 8.0, start_time_hour: '9', start_time_minute: '00', start_time_period: 'AM', end_time_hour: '5', end_time_minute: '00', end_time_period: 'PM' } }
    let(:new_shift_id) { shift.id }
    it "deletes the shift and redirects" do
      user = FactoryBot.create(:user)
      sign_in user
      delete :destroy, params: params
      expect(Shift.count).to eq(1)
      expect(Shift.last.default).to be true
      expect(response).to redirect_to(customers_path)
    end
  end

end