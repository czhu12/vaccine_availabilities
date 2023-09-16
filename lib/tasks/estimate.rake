require 'csv'
ZIP_CODE_CSV = CSV.parse(
  File.read(File.join('lib', 'assets', 'zip_codes.csv')),
  headers: true 
)
COOKIE = 'mdLogger=false; kampyle_userid=1190-afbc-179b-2c40-0959-83f5-e324-dec8; dtm_token=AQENsFdMieCxHgEe0noZAQELPgE; _mibhv=anon-1686882194869-5285243028_6787; dtm_token_sc=AAAMsVZNiOGwHwAf03sYAAAAAAE; _ga=GA1.2.1978793031.1689196804; _ga_EDHN1R1DQZ=GS1.2.1691425120.2.1.1691425230.0.0.0; rxVisitor=1691425244585L5FAPQNQPQ8DG933350ABEIEJLQVU31P; uts=1691425245144; session_id=38d7e238-218d-4510-bf9e-93cb2aef0468; XSRF-TOKEN=T4dFWoDhMKFBvg==.E3KtMCUHJZIiu21p5v08/ri53bkOJOVZnPFeEhtiR7s=; at_check=true; AMCVS_5E16123F5245B2970A490D45%40AdobeOrg=1; s_cc=true; dtCookie=v_4_srv_27_sn_4C3A3C29506665CAD11545880BD516F8_app-3A0eed2717dafcc06d_1_ol_0_perc_100000_mul_1_rcs-3Acss_0; gRxAlDis=N; str_nbr_do=4372; USER_LOC=2%2BsKJSc9HtIYvtnO6Ec58DufCKUgUi6A9MclPeGQbILEE5zKiQLmNNGp6qnjoHjb; CONF=XP3EV8AWIKJVS6; _uetvid=be0c21600bec11ee97de133e649dedd7; ps=15246; alg_idx_qry={"indexNames":["productSku"],"queryIds":["438e9419755229a22b21af3c9fe8f317"]}; strOfrId={"WAStrId":"4372","WAStrSt":"780 E SANTA CLARA ST"}; UGL=%7B%22pdStrId%22%3A%224372%22%2C%22pdStrIdZp%22%3A%2295112%22%2C%22pdStrIdSt%22%3A%22780%20E%20SANTA%20CLARA%20ST%22%7D; Tld-kampyleUserSession=1693249899416; Tld-kampyleUserSessionsCount=18; Tld-kampyleUserPercentile=38.52964857913117; imm_guest=s%3Aw6DElMSawq%2FEnsOqw7fEl0vCqMS9xLglxbjDucSQxagvw5sixYllxIrDhsOVxaDCrMSETMWiL8OCxLE9xZXEusSZw7bDn1XDmMWBUcK6ZsSmasWkw5E7W8S7w63Fn8O8xLPDlsKjxIHFjMO8TsSQw5TFv8O9w7FXxLpGxJ5kw6vFlcOoNMS7w5HCp314cGzDhD4%2FxKPEucSmxInFv0vEp8OyxbjCvsO3w5nDvMOsZsW1.szSYQr%2FiIMMXi6Y9lD41%2B9MvSSvCX6f35qeQDAfIrh0; AKA_A2=A; bm_sz=FBD92C691B11DFBB6F562D2A1CB0865D~YAAQK05DFyitj4+KAQAAzpH9nxWqyaVvqEgk4Rjc4GFN5C0uR6VHGWxo7ClIRDJ7I91XpNtGR5CGuNCm+4jagGmb1e/vWIAwjt/otGqMxu8g7CjRYQDgE2c/xNtoaApXt+/3t0SjPcjO3V/uApqkrHUPkJZ8y1SYMqYlmQcY386uunUPb2M3ToNzIv9ERkuWUAL8KQTSxhymxqp1FDZM98jcIX1e8P4/Z/VzOI0jYN/Lu/m7g/Xl88UEjZt8C/YAKzrOrr3wujTtn5abCUCosj8P8+GRgeG+hDeJNJMBbqk5cATWFSQ=~3162692~4604209; wag_sid=7os4gl09tr5qqhlgkegz2e3z; ak_bmsc=AB397761C64A9A08ADC636AE2BA28022~000000000000000000000000000000~YAAQK05DFxuvj4+KAQAAvp39nxUaU2om18mDWXs/vKvwXchaxQhNWiLj5o1IDTxdDmwvAohTbhmPhX54K7bsYOSFIajJQbRSFlLF8m9uyx1rfiKY9+9wE3HuYrxNVDQBApYqvWf/uJy0TRrYT8KpA3A0vn2i3VUGDpXg76rOwYYjIadp+ydPMIa+RKwCzn4UlUmzibCRb8Ck2USQL6wyaKPMawTPtk+u11mZ6K61nwMGrbzGXvpRiYeYTPjkpae0vgYlUGRFBHNXoTsfLNUnlscEg9/0r1oI6YkFVS735Bk05OrVeFjFl192QCSziTOdqxeKcykN0zrK16InWnAOEn9N5Q+mjDHqhMDQUKiVWA1VTn6K6xA6v1XPtU4OCofMqupI9+BBGsgLzBll6fsaj9jrrjTiJslFpQne8SmzlsCjdIEJjgn63AJsfzO1JtYctlPei+FicbqeCNCYlvVlv13f0lZcSBJJV9bpk4/OmdBh7yvnuVnaSRV1hk5l; AMCV_5E16123F5245B2970A490D45%40AdobeOrg=179643557%7CMCIDTS%7C19617%7CMCMID%7C43847841174578064481416578164456073971%7CMCAAMLH-1695506113%7C9%7CMCAAMB-1695506113%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1694908513s%7CNONE%7CvVersion%7C5.5.0; dtSa=-; fc_vnum=7; fc_vexp=true; mbox=PC#1ef821dc9bd74ddbb26d000240a14f60.35_0#1758146121|session#184520f984264d8793c5fff802747ba7#1694903181; OptanonConsent=isGpcEnabled=0&datestamp=Sat+Sep+16+2023+14%3A55%3A20+GMT-0700+(Pacific+Daylight+Time)&version=202306.1.0&isIABGlobal=false&hosts=&consentId=73fb0148-7a07-4d55-89cc-a820779c5c71&interactionCount=1&landingPath=NotLandingPage&groups=C0004%3A1%2CC0007%3A0%2CC0001%3A1%2CC0003%3A1%2CC0002%3A1%2CC0005%3A1&AwaitingReconsent=false&browserGpcFlag=0; Tld-kampyleSessionPageCounter=2; gpv_Page=https%3A%2F%2Fwww.walgreens.com%2Ffindcare%2Fschedule-vaccine%2Fmulti-vaccineList; _abck=2D9E0F2B5776D094835F33C68F397FE0~0~YAAQK05DF5DKj4+KAQAAlVv+nwotmBZ95Rv2GXFT3i8whrXCXLJIOfF9UFchJUbSzsQiuL9R5f4fq4EkcwQ8nEjjGbYEdqB/syZYt7xwFlAajGdyXsJzEkA3wBSSKopPw9UYX6JBzMWWZSTLCbkUcbdPwlraBAzby1vOZjXKRSFp1VBCA720Kc3D493HTxAZJoKd5oF3dOWbd+rKZsn5sj2CAwzi2eNitugLxArGHiRCpTGfV2r5n+TAHpn8J4vbBfVZAovB/MZrKs/Myc9/xRK1eURjP0n0egFwP1mhgWNZ9iTz4ZKoPeMsNWvvnwHHUzQF00nvYUb6FuIsbh3mX8GbayeTcTDtSRlNcqgwJERbIKHM9PLFAko1hCdPOqU2w1jqm97y9fmVzW0uHIQnui5BtpUUzewlk1q3~-1~-1~-1; akavpau_walgreens=1694901672~id=64cc287c7862dd5700400dd6ee6847b1; bm_sv=7787409EE9A11F72C5D244324983A614~YAAQK05DF3DSj4+KAQAAHY/+nxUn7jSwK0fUjUsiF5QLt/lVYP3aRLi2xYNWOP8CtNaiHyBAAZb/xWlD0eBl7AAh8qmv9emGupBg3XZ5A8iyflSiYr3AY3/WWVJpxvMUbtlmG1XhsgWc4eefagWoYGSjMVuwBigBw1QEULUjvwrZEmd76AF0XUE+I3osrtq6hp3aItlHQo/Z/gmSvBANM8kEIkHMUGz6xxgS08TsCWC6Db6PP6vRhvJTT9x7m0G1JR32FQ==~1; RT="z=1&dm=www.walgreens.com&si=74d9f68b-becf-4b94-ab1b-d5ca776363be&ss=lmmkh78v&sl=2&tt=3lt&obo=1&rl=1&ld=9xj&nu=9y8m6cy&cl=1fpz"; s_sq=walgrns%3D%2526pid%253Dwg%25253Afindcare%25253Avaccinations%25253Aselector%2526pidt%253D1%2526oid%253Dfunctionnoop%252528%252529%25257B%25257D%2526oidt%253D2%2526ot%253DA; rxvt=1694903175260|1694901310760; dtPC=27$501317821_754h26vKEDKQJNVTSHRREPAAVBUFDVWTJHEOMMD-0e0'
XSRF_TOKEN = "nPTWCo2a0sju9A==.2Egr5z83QDsXUkqylPiGgiuk0xo6rGemiNPP4N0bzTs="

namespace :estimate do
  def fetch_locations_for_address(address, retailer:)
    if retailer == :cvs
    elsif retailer == :walgreens
      fetch_locations_for_walgreens(address)
    end
  end

  def cached(cache_keys, data_type:)
    Cache.where(key: cache_keys.join("--")).first_or_create do |cache|
      data = yield
      cache.data = JSON.dump(data)
      cache.data_type = data_type
      cache.save!
    end
  end

  def zip_codes
    ZIP_CODE_CSV.map do |row|
      yield row['zipcode'], row['state_abbr'], row
    end
  end

  task vaccines: :environment do
    zip_codes do |zip_code, state_abbr, _|
      [:cvs, :walgreens].each do |retailer|
        fetch_locations_for_address([zip_code, state_abbr], retailer:)
      end
    end
  end

  def fetch_locations_for_walgreens(address, state)
    zip_code, state_abbr = address
    loc = Geocoder.search("#{zip_code} #{state}").first
    latitude = loc.latitude
    longitude = loc.longitude
    dates = [Date.today, Date.today + 7.days]
    dates.each do |date|
      body = {
        "position": {
            "latitude": latitude,
            "longitude": longitude
        },
        "state": state_abbr,
        "vaccine": [
            {
                "code": "207",
                "productId": ""
            }
        ],
        "appointmentAvailability": {
            "startDateTime": date.to_s
        },
        "filter": {
            "radius": 25,
            "size": 25,
            "pageNo": 1,
            "includeUnavailableStores": false
        },
        "serviceId": "99",
        "restriction": {
            "dob": "1993-12-03"
        }
      }
      cached(["walgreens", "locations", zip_code, date], data_type: :walgreens_locations) do
        response = HTTParty.post(
          "https://www.walgreens.com/hcschedulersvc/svc/v8/immunizationLocations/timeslots",
          body: body.to_json,
          headers: {
            "X-XSRF-TOKEN": XSRF_TOKEN,
            "Cookie": COOKIE,
            "Accept": 'application/json',
          },
        )
        body = JSON.parse(response.body)
      end
    end
  end

  def fetch_availabilities_for_location_id()
  end
end