# frozen_string_literal: true

class Retailers::Walgreens::QueryServices < Retailers::QueryServices
  MANUFACTURER_MAPPING = {
    pfizer: 'Pfizer-BioNtech',
    moderna: 'Moderna',
    johnson_and_johnson: 'Janssen'
  }.freeze

  SERVICE_DATA = JSON.parse(File.read(File.join(__dir__, 'services.json')))

  def query
    services_data.map do |s_data|
      parse_data(s_data)
    end
  end

  def query_for_book_appt
    services_data.map do |s_data|
      {
        code: s_data['vaccineCode'],
        productId: s_data['productId'],
        dose: '1',
        type: 'Regular'
      }
    end
  end

  def services_data
    @services_data ||= [SERVICE_DATA.find do |s|
      brands.include? s['manufacturer']
    end].compact
  end

  def codes
    query.map { |s| s[:code] }
         .uniq
  end

  private

    def brands
      @brands ||= services.map { |s| MANUFACTURER_MAPPING[s.brand.to_sym] }.uniq
    end

    def parse_data(data)
      {
        vaccineCode: data['vaccineCode'],
        code: data['vaccineCode'],
        productId: data['productId'],
        name: 'COVID-19 Vaccine',
        type: 'Regular',
        dose: '1',
        manufacturer: data['manufacturer']
      }
    end
end
