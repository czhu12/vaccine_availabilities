# frozen_string_literal: true

class Retailers::Walgreens::BookAppointment < Retailers::BookAppointment
  RACE = {
    unknown: { code: 'UNK', description: 'UNK' },
    american_indian_alaska_native: { code: '1002-5', description: 'American Indian or Alaska Native' },
    asian: { code: '2028-9', description: 'Asian' },
    black: { code: '2054-5', description: 'Black or African American' },
    native_hawaiian_pacific_islander: { code: '2076-8', description: 'Native Hawaiian or Other Pacific Islander' },
    white: { code: '2106-3', description: 'White' },
    other: { code: '2131-1', description: 'Other Race' }
  }.freeze

  def query_services
    @query_services ||= Retailers::Walgreens::QueryServices.new(services: appointment.services, user:)
  end

  required_field 'user.email'
  required_field 'user.sex'

  def create_engagement
    Retailers::Walgreens::Client.new.post(
      '/hcimmunizationsvc/svc/v5/engagement',
      {
        coverage: 'Yes',
        availabilityGroup: 'General',
        languagePreference: 'en',
        channel: 'Web',
        client: 'Customer',
        engagementType: 'Guest',
        userResponses: [
          {
            vaccineCode: query_services.codes.first,
            details: [
              {
                question: 'Patient immunocompromised',
                answer: 'No'
              }
            ]
          }
        ]
      },
      type: 'Engagement'
    )
  end

  def create_hold(engagement_id)
    Retailers::Walgreens::Client.new.post(
      '/hcappointmentsvc/svc/v6/appointment/hold',
      [
        {
          serviceType: [
            {
              code: '57',
              display: 'Immunizations'
            }
          ],
          vaccines: query_services.query_for_book_appt,
          locationId: location.external_id,
          organizationId: location.metadata['organizationId'],
          appointmentDate: time_slot.date_time.strftime('%Y-%m-%dT%H:%M:%S%Z'),
          slot: time_slot.date_time.strftime('%I:%M %P'),
          engagementId: engagement_id,
          appointmentType: 'checkup',
          availabilityGroup: 'General'
        }
      ],
      type: 'Hold'
    )
  end

  def create_patient(engagement_id)
    Retailers::Walgreens::Client.new.post(
      '/hcimmunizationsvc/svc/v3/patient',
      {
        engagementId: engagement_id,
        firstName: user.first_name,
        lastName: user.last_name,
        gender: user.sex.capitalize,
        contact: {
          phones: [
            {
              type: 'Mobile',
              number: phone_number
            }
          ],
          emails: [
            {
              type: 'Email',
              address: user.email
            }
          ]
        },
        race:,
        ethnicity:,
        organizationId: location.metadata['organizationId'],
        dob: user.date_of_birth.strftime('%Y-%m-%d')
      },
      type: 'Patient'
    )
  end

  def create_consent(engagement_id:, patient_id:)
    Retailers::Walgreens::Client.new.patch(
      '/hcappointmentsvc/svc/v5/appointment/consent',
      {
        engagementId: engagement_id,
        patientId: patient_id,
        phoneNumber: user.phone_number,
        consentDecision: 'Agree'
      },
      type: 'Consent'
    )
  end

  def create_appointment(engagement_id:, patient_id:)
    Retailers::Walgreens::Client.new.patch(
      '/hcappointmentsvc/svc/v6/appointment/confirm',
      {
        engagementId: engagement_id,
        patientId: patient_id
      },
      type: 'Appointment'
    )
  end

  def self.url(_appointment)
    # no set url with confirmation code
    "#{Retailers::Walgreens::Client.base_uri}/findcare/schedule-vaccine/manage-appointment"
  end

  def query!
    engagement_id = create_engagement['engagementId']
    create_hold(engagement_id)
    patient_id = create_patient(engagement_id)['patientId']
    create_consent(engagement_id:, patient_id:)
    # Will fail, requires session cookie
    response = create_appointment(engagement_id:, patient_id:)

    { id: response['confirmationNumber'] }
  end

  private

    def race
      race = user.race.blank? ? RACE[:unknown] : RACE[user.race]
      return race if race.present?
    end

    def ethnicity
      return { code: 'UNK', description: 'Unknown ethnicity' } if user.ethnicity.blank?

      if user.hispanic?
        { code: '2135-2', description: 'Hispanic or Latino' }
      else
        { code: '2186-5', description: 'Non Hispanic or Latino' }
      end
    end

    def phone_number
      user.phone_number
          .phony_formatted(format: '%{trunk}%{ndc}-%{local}') # 408-555-7810
    end
end
