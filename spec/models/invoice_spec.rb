# frozen_string_literal: true

describe Invoice, type: :model do
  let(:event) { FactoryBot.create :event }

  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :invoiceable }
  end

  describe '.from_attendance' do
    let!(:period) { FactoryBot.create(:registration_period, event: event, start_at: 1.month.ago, end_at: 1.month.from_now, price: 100) }
    let(:group) { RegistrationGroup.create! event: event, discount: 20 }
    let!(:attendance) { FactoryBot.create(:attendance, event: event, registration_value: 100) }

    context 'with no pending invoice already existent' do
      subject(:invoice) { Invoice.from_attendance(attendance, 'gateway') }
      it { expect(invoice.user).to eq attendance.user }
      it { expect(invoice.invoiceable).to eq attendance }
      it { expect(Money.new(invoice.amount * 100, :BRL)).to eq attendance.event.registration_price_for(attendance, 'gateway') }
    end

    context 'with an already registered invoice for another user' do
      let(:user) { FactoryBot.create :user }
      let!(:invoice) { FactoryBot.create(:invoice, user: user, amount: 200, payment_type: 'gateway') }
      let!(:attendance) { FactoryBot.create(:attendance, event: event, registration_value: 100) }
      subject!(:other_invoice) { Invoice.from_attendance(attendance, 'gateway') }
      it { expect(other_invoice.user).to eq attendance.user }
      it { expect(other_invoice.invoiceable).to eq attendance }
      it { expect(other_invoice.amount).to eq 100 }
    end

    context 'with an already existent pending invoice' do
      let!(:invoice) { FactoryBot.create(:invoice, user: attendance.user, invoiceable: attendance, amount: 100, payment_type: 'gateway') }
      subject!(:other_invoice) { Invoice.from_attendance(attendance, 'gateway') }
      it { expect(other_invoice).to eq invoice }
      it { expect(Invoice.count).to eq 1 }
    end
  end

  describe '.from_registration_group' do
    let(:user) { FactoryBot.create :user }
    let(:group) { FactoryBot.create :registration_group, leader: user }

    context 'with no pending invoice already existent' do
      subject(:invoice) { Invoice.from_registration_group(group, 'gateway') }
      it { expect(invoice.invoiceable).to eq group }
      it { expect(invoice.user).to eq group.leader }
    end

    context 'with an already registered invoice for another user' do
      let(:other_user) { FactoryBot.create :user }
      let!(:invoice) { FactoryBot.create(:invoice, user: group.leader, invoiceable: group, amount: 200, payment_type: 'gateway') }
      let!(:other_group) { FactoryBot.create(:registration_group, leader: other_user) }
      let!(:attendance) { FactoryBot.create(:attendance, event: event, user: other_user, registration_group: other_group, registration_value: 100) }
      subject!(:other_invoice) { Invoice.from_attendance(attendance, 'gateway') }
      it { expect(other_invoice.user).to eq other_group.leader }
      it { expect(other_invoice.amount).to eq 100 }
    end

    context 'with an already existent invoice' do
      context 'with same total price' do
        let!(:invoice) { FactoryBot.create(:invoice, invoiceable: group, amount: group.total_price, payment_type: 'gateway') }
        subject!(:other_invoice) { Invoice.from_registration_group(group, 'gateway') }
        it { expect(other_invoice).to eq invoice }
        it { expect(Invoice.count).to eq 1 }
        it { expect(Invoice.last.amount).to eq group.total_price }
      end

      context 'with different total price' do
        let!(:invoice) { FactoryBot.create(:invoice, invoiceable: group, amount: 100, payment_type: 'gateway') }
        let!(:other_attendance) { FactoryBot.create(:attendance, event: event, user: user, registration_group: group, registration_value: 200) }

        subject!(:other_invoice) { Invoice.from_registration_group(group, 'gateway') }
        it { expect(other_invoice.amount).to eq 200 }
        it { expect(Invoice.count).to eq 1 }
      end
    end
  end

  describe '.for_attendance' do
    let(:attendance) { FactoryBot.create(:attendance) }
    let(:other_attendance) { FactoryBot.create(:attendance) }
    let(:invoice) { FactoryBot.create(:invoice, status: :pending, invoiceable: attendance) }
    let(:other_invoice) { FactoryBot.create(:invoice, status: :pending, invoiceable: other_attendance) }

    it { expect(Invoice.for_attendance(attendance.id)).to eq [invoice] }
  end

  describe '.active' do
    let(:invoice) { FactoryBot.create(:invoice, status: :pending) }
    let(:paid_invoice) { FactoryBot.create(:invoice, status: :paid) }
    let(:other_invoice) { FactoryBot.create(:invoice, status: :cancelled) }

    it { expect(Invoice.active).to match_array [invoice, paid_invoice] }
  end

  describe '#pay_it!' do
    let(:invoice) { FactoryBot.create :invoice }
    before { invoice.pay_it! }
    it { expect(invoice.status).to eq Invoice::PAID }
  end

  describe '#send_it!' do
    let(:invoice) { FactoryBot.create :invoice }
    before { invoice.send_it! }
    it { expect(invoice.status).to eq Invoice::SENT }
  end

  describe '#pending?' do
    context 'with a pending invoice' do
      let(:invoice) { FactoryBot.create :invoice, status: Invoice::PENDING }
      it { expect(invoice.pending?).to be_truthy }
    end

    context 'with a paid invoice' do
      let(:invoice) { FactoryBot.create :invoice, status: Invoice::PAID }
      it { expect(invoice.pending?).to be_falsey }
    end

    context 'with a sent invoice' do
      let(:invoice) { FactoryBot.create :invoice, status: Invoice::SENT }
      it { expect(invoice.pending?).to be_falsey }
    end
  end

  describe '#cancel_it!' do
    let(:invoice) { FactoryBot.create :invoice }
    before { invoice.cancel_it! }
    it { expect(invoice.status).to eq Invoice::CANCELLED }
  end

  context 'enums' do
    it { is_expected.to define_enum_for(:payment_type).with(gateway: 1, bank_deposit: 2, statement_agreement: 3) }
  end
end
