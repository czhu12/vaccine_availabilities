# frozen_string_literal: true

class Retailers::Walgreens::CancelAppointment < Retailers::CancelAppointment
  def query_appointment_id
    response = Retailers::Walgreens::Client.new.post(
      '/hcappointmentsvc/svc/v6/appointments/search',
      {
        confirmationNumber: appointment.external_id,
        dob: user_dob
      }
    )
    response.dig('appointments', 0, 'appointment', 'appointmentId')
  end

  def query!
    # Will fail, requires session cookie
    appointment_id = query_appointment_id
    Retailers::Walgreens::Client.new.patch(
      "/hcappointmentsvc/svc/v6/appointment/#{appointment.external_id}/cancel",
      {
        reason: '',
        canceledBy: 'patient',
        dob: user_dob,
        appointmentId: appointment_id
      }
    )
  end

  private

    def user_dob
      @user_dob ||= appointment.user.date_of_birth.strftime('%Y-%m-%d')
    end
end
