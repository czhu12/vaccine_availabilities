require 'csv'
ZIP_CODE_CSV = File.read(File.join('lib', 'assets', 'zip_codes.csv'))
namespace :estimate do
  task vaccines: :environment do
    rows = CSV.parse(ZIP_CODE_CSV, headers: true)
    rows.each do |row|
      row['zipcode']
    end
    puts "Hello"
  end
end