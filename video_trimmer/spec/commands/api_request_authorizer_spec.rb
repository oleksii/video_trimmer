require 'rails_helper'

RSpec.describe ApiRequestAuthorizer do
  subject { described_class.call(headers) }

  context 'with valid auth token in headers' do
    let(:user)    { create(:user) }
    let(:token)   { JsonWebToken.encode(user_id: user.id.to_s) }
    let(:headers) { { 'Authorization' => token } }

    it 'returns the user' do
      expect(subject.success?).to be(true)
      expect(subject.errors).to eq({})
      expect(subject.result).to eq(user)
    end
  end

  context 'with not valid auth token in headers' do
    let(:headers) { { 'Authorization' => 'wrong token' } }

    it 'returns "Invalid token" error' do
      expect(subject.success?).to be(false)
      expect(subject.errors).to eq({token: ['Invalid token']})
      expect(subject.result).to be(nil)
    end
  end

  context 'without auth token in headers' do
    let(:headers) { {} }

    it 'returns "Missing token" error' do
      expect(subject.success?).to be(false)
      expect(subject.errors).to eq({token: ['Missing token']})
      expect(subject.result).to be(nil)
    end
  end
end
