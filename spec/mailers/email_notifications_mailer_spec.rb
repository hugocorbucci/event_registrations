# frozen_string_literal: true

RSpec.describe EmailNotificationsMailer, type: :mailer do
  let(:event) { Fabricate :event, link: 'www.foo.com' }

  before { ActionMailer::Base.deliveries = [] }

  after { ActionMailer::Base.deliveries.clear }

  describe '#registration_pending' do
    let(:attendance) { Fabricate(:attendance, event: event) }

    context 'having organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee and cc the events organizer' do
        mail = described_class.registration_pending(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#registration_waiting' do
    let(:attendance) { Fabricate(:attendance, event: event, status: :waiting) }

    context 'having organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.registration_waiting(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#registration_confirmed' do
    let(:attendance) { Fabricate(:attendance, event: event, registration_date: Time.zone.local(2013, 5, 1, 12, 0, 0)) }

    context 'when the event starts before the end date' do
      it 'sends the confirmation' do
        mail = described_class.registration_confirmed(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.subject).to eq("Inscrição para #{event.name} confirmada")
      end
    end

    context 'with organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.registration_confirmed(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#cancelling_registration' do
    let(:event) { Fabricate :event }
    let(:attendance) { Fabricate :attendance, event: event }

    it 'sends to pending attendee' do
      mail = described_class.cancelling_registration(attendance).deliver
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.subject).to eq("Aviso de cancelamento da inscrição #{attendance.id} para #{event.name}")
    end

    context 'with organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.cancelling_registration(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#cancelling_registration_warning' do
    let(:event) { Fabricate :event }
    let(:attendance) { Fabricate :attendance, event: event }

    it 'is sent to pending attendee' do
      mail = described_class.cancelling_registration_warning(attendance).deliver
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.subject).to eq("Lembrete de pagamento da inscrição #{attendance.id} para #{event.name}")
    end

    context 'with organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.cancelling_registration_warning(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#registration_dequeued' do
    let(:attendance) { Fabricate(:attendance, event: event) }

    context 'having organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee and cc the events organizer' do
        mail = described_class.registration_dequeued(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#welcome_attendance' do
    let(:event) { Fabricate(:event, start_date: 1.day.from_now) }
    let(:out_event) { Fabricate(:event, start_date: 2.days.from_now) }
    let(:attendance) { Fabricate(:attendance, event: event) }
    let(:out_attendance) { Fabricate(:attendance, event: out_event) }

    context 'having organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, start_date: 1.day.from_now, organizers: [organizer, other_organizer] }

      it 'sends to attendee and cc the events organizer' do
        mail = described_class.welcome_attendance(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end
end
