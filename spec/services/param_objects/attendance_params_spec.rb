# frozen_string_literal: true

RSpec.describe AttendanceParams, type: :param_object do
  let(:user) { Fabricate :user, role: :organizer }
  let(:user_for_attendance) { Fabricate :user }
  let(:event) { Fabricate :event, organizers: [user] }

  describe '#new_attributes' do
    it 'returns all parameters for attendance' do
      valid_attendance = { attendance:
                             {
                               event_id: event.id,
                               user_id: user_for_attendance.id,
                               user_for_attendance: user_for_attendance.id,
                               organization: 'organization',
                               country: user.country,
                               state: 'sc',
                               city: user.city,
                               badge_name: 'badge_name'
                             } }
      params = ActionController::Parameters.new(valid_attendance)
      params_object = described_class.new(user, event, params)
      expect(params_object.new_attributes[:event_id]).to eq event.id
      expect(params_object.new_attributes[:user_id]).to eq user_for_attendance.id
      expect(params_object.new_attributes[:registered_by_id]).to eq user.id
      expect(params_object.new_attributes[:organization]).to eq 'organization'
      expect(params_object.new_attributes[:country]).to eq user.country
      expect(params_object.new_attributes[:state]).to eq 'SC'
      expect(params_object.new_attributes[:city]).to eq user.city
      expect(params_object.new_attributes[:badge_name]).to eq 'badge_name'

      expect(params_object.event).to eq event
    end
  end

  describe '#payment_type_params' do
    it 'knows how to return the payment type params' do
      valid_attendance = { payment_type: 'bank_deposit' }

      params = ActionController::Parameters.new(valid_attendance)
      params_object = described_class.new(user, event, params)

      expect(params_object.payment_type_params).to eq 'bank_deposit'
    end
  end

  describe '#attributes_hash' do
    it 'returns the hash with the attributes' do
      valid_attendance = { attendance:
                             {
                               event_id: event.id,
                               user_id: user_for_attendance.id,
                               organization: 'organization',
                               country: user.country,
                               state: user.state,
                               city: user.city,
                               badge_name: 'badge_name'
                             } }

      params = ActionController::Parameters.new(valid_attendance)
      params_object = described_class.new(user, event, params)
      expected_return = {
        'event_id' => event.id,
        'user_id' => user_for_attendance.id,
        'organization' => 'organization',
        'country' => user.country,
        'state' => user.state,
        'city' => user.city,
        'badge_name' => 'badge_name'
      }

      expect(params_object.attributes_hash.to_h).to eq expected_return
    end
  end
end
