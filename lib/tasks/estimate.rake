$stdout.sync = true
require 'csv'
require "uri"
require "json"
require "net/http"

ZIP_CODE_CSV = CSV.parse(
  File.read(File.join('lib', 'assets', 'zip_codes.csv')),
  headers: true 
)
ZIP_CODE_TO_STATE = ZIP_CODE_CSV.each_with_object({}) do |row, obj|
  obj[row['zipcode']] = row['state_abbr']
end

ZIP_CODES_TO_USE_CSV = CSV.parse(
  File.read(File.join('lib', 'assets', 'zip_codes_to_use.csv')),
  headers: true
)

CVS_NDC_DATA = [
  {
    "immunizationCode": "CVD",
    "name": "PFIZER 2023-24 COVID 12YR+ VL",
    "displayName": "Pfizer",
    "ndcInfo": [
      {
        "ndc": "00069236210",
        "minAge": 12,
        "maxAge": 150,
        "addlDoseDaysMin": 0,
        "addlDoseDaysMax": 0,
        "daysScheduleMin": 4,
        "daysScheduleMax": 14,
        "type": 6,
        "boosterDoseDaysMin": 1,
        "imzMinAge": 5,
        "imzMaxAge": 150
      }
    ]
  },
  {
    "immunizationCode": "CVD",
    "name": "PFIZER 2023-24 COVID 12YR+ SYR",
    "displayName": "Pfizer",
    "ndcInfo": [
      {
        "ndc": "00069239210",
        "minAge": 12,
        "maxAge": 150,
        "addlDoseDaysMin": 0,
        "addlDoseDaysMax": 0,
        "daysScheduleMin": 4,
        "daysScheduleMax": 14,
        "type": 6,
        "boosterDoseDaysMin": 1,
        "imzMinAge": 5,
        "imzMaxAge": 150
      }
    ]
  },
  {
    "immunizationCode": "CVD",
    "name": "MODERNA 2023-24 12 YR+ SYR",
    "displayName": "Moderna",
    "ndcInfo": [
      {
        "ndc": "80777010293",
        "minAge": 12,
        "maxAge": 150,
        "addlDoseDaysMin": 0,
        "addlDoseDaysMax": 0,
        "daysScheduleMin": 4,
        "daysScheduleMax": 14,
        "type": 6,
        "boosterDoseDaysMin": 1,
        "imzMinAge": 5,
        "imzMaxAge": 150
      },
      {
        "ndc": "80777010296",
        "minAge": 12,
        "maxAge": 150,
        "addlDoseDaysMin": 0,
        "addlDoseDaysMax": 0,
        "daysScheduleMin": 4,
        "daysScheduleMax": 14,
        "type": 6,
        "boosterDoseDaysMin": 1,
        "imzMinAge": 5,
        "imzMaxAge": 150
      }
    ]
  },
  {
    "immunizationCode": "CVD",
    "name": "MODERNA 2023-24 12 YR+ VIAL",
    "displayName": "Moderna",
    "ndcInfo": [
      {
        "ndc": "80777010295",
        "minAge": 12,
        "maxAge": 150,
        "addlDoseDaysMin": 0,
        "addlDoseDaysMax": 0,
        "daysScheduleMin": 4,
        "daysScheduleMax": 14,
        "type": 6,
        "boosterDoseDaysMin": 1,
        "imzMinAge": 5,
        "imzMaxAge": 150
      }
    ]
  },
]
COOKIE = 'mdLogger=false; kampyle_userid=1190-afbc-179b-2c40-0959-83f5-e324-dec8; dtm_token=AQENsFdMieCxHgEe0noZAQELPgE; _mibhv=anon-1686882194869-5285243028_6787; dtm_token_sc=AAAMsVZNiOGwHwAf03sYAAAAAAE; _ga=GA1.2.1978793031.1689196804; _ga_EDHN1R1DQZ=GS1.2.1691425120.2.1.1691425230.0.0.0; rxVisitor=1691425244585L5FAPQNQPQ8DG933350ABEIEJLQVU31P; uts=1691425245144; session_id=38d7e238-218d-4510-bf9e-93cb2aef0468; XSRF-TOKEN=T4dFWoDhMKFBvg==.E3KtMCUHJZIiu21p5v08/ri53bkOJOVZnPFeEhtiR7s=; at_check=true; AMCVS_5E16123F5245B2970A490D45%40AdobeOrg=1; s_cc=true; dtCookie=v_4_srv_27_sn_4C3A3C29506665CAD11545880BD516F8_app-3A0eed2717dafcc06d_1_ol_0_perc_100000_mul_1_rcs-3Acss_0; gRxAlDis=N; str_nbr_do=4372; USER_LOC=2%2BsKJSc9HtIYvtnO6Ec58DufCKUgUi6A9MclPeGQbILEE5zKiQLmNNGp6qnjoHjb; CONF=XP3EV8AWIKJVS6; _uetvid=be0c21600bec11ee97de133e649dedd7; ps=15246; alg_idx_qry={"indexNames":["productSku"],"queryIds":["438e9419755229a22b21af3c9fe8f317"]}; strOfrId={"WAStrId":"4372","WAStrSt":"780 E SANTA CLARA ST"}; UGL=%7B%22pdStrId%22%3A%224372%22%2C%22pdStrIdZp%22%3A%2295112%22%2C%22pdStrIdSt%22%3A%22780%20E%20SANTA%20CLARA%20ST%22%7D; Tld-kampyleUserSession=1693249899416; Tld-kampyleUserSessionsCount=18; Tld-kampyleUserPercentile=38.52964857913117; imm_guest=s%3Aw6DElMSawq%2FEnsOqw7fEl0vCqMS9xLglxbjDucSQxagvw5sixYllxIrDhsOVxaDCrMSETMWiL8OCxLE9xZXEusSZw7bDn1XDmMWBUcK6ZsSmasWkw5E7W8S7w63Fn8O8xLPDlsKjxIHFjMO8TsSQw5TFv8O9w7FXxLpGxJ5kw6vFlcOoNMS7w5HCp314cGzDhD4%2FxKPEucSmxInFv0vEp8OyxbjCvsO3w5nDvMOsZsW1.szSYQr%2FiIMMXi6Y9lD41%2B9MvSSvCX6f35qeQDAfIrh0; AKA_A2=A; bm_sz=FBD92C691B11DFBB6F562D2A1CB0865D~YAAQK05DFyitj4+KAQAAzpH9nxWqyaVvqEgk4Rjc4GFN5C0uR6VHGWxo7ClIRDJ7I91XpNtGR5CGuNCm+4jagGmb1e/vWIAwjt/otGqMxu8g7CjRYQDgE2c/xNtoaApXt+/3t0SjPcjO3V/uApqkrHUPkJZ8y1SYMqYlmQcY386uunUPb2M3ToNzIv9ERkuWUAL8KQTSxhymxqp1FDZM98jcIX1e8P4/Z/VzOI0jYN/Lu/m7g/Xl88UEjZt8C/YAKzrOrr3wujTtn5abCUCosj8P8+GRgeG+hDeJNJMBbqk5cATWFSQ=~3162692~4604209; wag_sid=7os4gl09tr5qqhlgkegz2e3z; ak_bmsc=AB397761C64A9A08ADC636AE2BA28022~000000000000000000000000000000~YAAQK05DFxuvj4+KAQAAvp39nxUaU2om18mDWXs/vKvwXchaxQhNWiLj5o1IDTxdDmwvAohTbhmPhX54K7bsYOSFIajJQbRSFlLF8m9uyx1rfiKY9+9wE3HuYrxNVDQBApYqvWf/uJy0TRrYT8KpA3A0vn2i3VUGDpXg76rOwYYjIadp+ydPMIa+RKwCzn4UlUmzibCRb8Ck2USQL6wyaKPMawTPtk+u11mZ6K61nwMGrbzGXvpRiYeYTPjkpae0vgYlUGRFBHNXoTsfLNUnlscEg9/0r1oI6YkFVS735Bk05OrVeFjFl192QCSziTOdqxeKcykN0zrK16InWnAOEn9N5Q+mjDHqhMDQUKiVWA1VTn6K6xA6v1XPtU4OCofMqupI9+BBGsgLzBll6fsaj9jrrjTiJslFpQne8SmzlsCjdIEJjgn63AJsfzO1JtYctlPei+FicbqeCNCYlvVlv13f0lZcSBJJV9bpk4/OmdBh7yvnuVnaSRV1hk5l; AMCV_5E16123F5245B2970A490D45%40AdobeOrg=179643557%7CMCIDTS%7C19617%7CMCMID%7C43847841174578064481416578164456073971%7CMCAAMLH-1695506113%7C9%7CMCAAMB-1695506113%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1694908513s%7CNONE%7CvVersion%7C5.5.0; dtSa=-; fc_vnum=7; fc_vexp=true; mbox=PC#1ef821dc9bd74ddbb26d000240a14f60.35_0#1758146121|session#184520f984264d8793c5fff802747ba7#1694903181; OptanonConsent=isGpcEnabled=0&datestamp=Sat+Sep+16+2023+14%3A55%3A20+GMT-0700+(Pacific+Daylight+Time)&version=202306.1.0&isIABGlobal=false&hosts=&consentId=73fb0148-7a07-4d55-89cc-a820779c5c71&interactionCount=1&landingPath=NotLandingPage&groups=C0004%3A1%2CC0007%3A0%2CC0001%3A1%2CC0003%3A1%2CC0002%3A1%2CC0005%3A1&AwaitingReconsent=false&browserGpcFlag=0; Tld-kampyleSessionPageCounter=2; gpv_Page=https%3A%2F%2Fwww.walgreens.com%2Ffindcare%2Fschedule-vaccine%2Fmulti-vaccineList; _abck=2D9E0F2B5776D094835F33C68F397FE0~0~YAAQK05DF5DKj4+KAQAAlVv+nwotmBZ95Rv2GXFT3i8whrXCXLJIOfF9UFchJUbSzsQiuL9R5f4fq4EkcwQ8nEjjGbYEdqB/syZYt7xwFlAajGdyXsJzEkA3wBSSKopPw9UYX6JBzMWWZSTLCbkUcbdPwlraBAzby1vOZjXKRSFp1VBCA720Kc3D493HTxAZJoKd5oF3dOWbd+rKZsn5sj2CAwzi2eNitugLxArGHiRCpTGfV2r5n+TAHpn8J4vbBfVZAovB/MZrKs/Myc9/xRK1eURjP0n0egFwP1mhgWNZ9iTz4ZKoPeMsNWvvnwHHUzQF00nvYUb6FuIsbh3mX8GbayeTcTDtSRlNcqgwJERbIKHM9PLFAko1hCdPOqU2w1jqm97y9fmVzW0uHIQnui5BtpUUzewlk1q3~-1~-1~-1; akavpau_walgreens=1694901672~id=64cc287c7862dd5700400dd6ee6847b1; bm_sv=7787409EE9A11F72C5D244324983A614~YAAQK05DF3DSj4+KAQAAHY/+nxUn7jSwK0fUjUsiF5QLt/lVYP3aRLi2xYNWOP8CtNaiHyBAAZb/xWlD0eBl7AAh8qmv9emGupBg3XZ5A8iyflSiYr3AY3/WWVJpxvMUbtlmG1XhsgWc4eefagWoYGSjMVuwBigBw1QEULUjvwrZEmd76AF0XUE+I3osrtq6hp3aItlHQo/Z/gmSvBANM8kEIkHMUGz6xxgS08TsCWC6Db6PP6vRhvJTT9x7m0G1JR32FQ==~1; RT="z=1&dm=www.walgreens.com&si=74d9f68b-becf-4b94-ab1b-d5ca776363be&ss=lmmkh78v&sl=2&tt=3lt&obo=1&rl=1&ld=9xj&nu=9y8m6cy&cl=1fpz"; s_sq=walgrns%3D%2526pid%253Dwg%25253Afindcare%25253Avaccinations%25253Aselector%2526pidt%253D1%2526oid%253Dfunctionnoop%252528%252529%25257B%25257D%2526oidt%253D2%2526ot%253DA; rxvt=1694903175260|1694901310760; dtPC=27$501317821_754h26vKEDKQJNVTSHRREPAAVBUFDVWTJHEOMMD-0e0'
XSRF_TOKEN = "nPTWCo2a0sju9A==.2Egr5z83QDsXUkqylPiGgiuk0xo6rGemiNPP4N0bzTs="

namespace :estimate do
  def cvs_base_query(ndc, zip_code, date)
    {
      "requestMetaData": {
          "appName": "CVS_WEB",
          "lineOfBusiness": "RETAIL",
          "channelName": "WEB",
          "deviceType": "DESKTOP",
          "deviceToken": "7777",
          "apiKey": "a2ff75c6-2da7-4299-929d-d670d827ab4a",
          "source": "ICE_WEB",
          "securityType": "apiKey",
          "responseFormat": "JSON",
          "type": "cn-dep",
          "conversationID": ""
      },
      "requestPayloadData": {
        "distanceInMiles": 500,
        "patients": [
          {
            "immunizations": [
              {
                "imzType": "CVD",
                "ndc": [ndc],
                "allocationType": "3"
              }
            ],
            "dateOfBirth": "1993-12-03"
          }
        ],
        "startDate": date.to_s,
        "endDate": (date + 14.days).to_s,
        "searchCriteria": {
          "addressLine": zip_code
        }
      }
    }
  end

  def cvs_query(ndc, zip_code, date)
    url = URI("https://www.cvs.com/Services/ICEAGPV1/immunization/3.0.0/getIMZStores")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Cookie"] = "_abck=52F4BACBA3E102872DF6FD740C1AF240~-1~YAAQFTPFF3hrtIeKAQAASk74nwqTnv8VmztmqHQ1cEhbJP094Cq6gu3CGstGTqtSpXb6laLfyrk5BQyRU4crQVVogJ0XL8b32RvWNQIHiIEEqqau45iNjcEY9BGt9XtYq7oEf5Dc9VFMFSzydR3lRNH4UVFnqTo5dl3PJDfGa9a5YuIQ5KFZG04ij/9FhdBw9lEtkGG7VPTF+G3MYgQ4PUD1ImXx3OmK53U+GgLd8Nncj6Yzxg17CRlsMe/GvJgJW082wbWqJugup9v0ulaMrk3Oscz4w0Z3VUse+WMyJXNoJdZ5nctL1dE+Cg3XrnRV61H3UTyBsUBHpj7DD31lRmJw7DjZ0HIj1e+iHWpYKV5DTecr208=~-1~-1~-1; ak_bmsc=94DE131E0B0D56BC4B1CFE2D9A54DB4D~000000000000000000000000000000~YAAQFTPFF3lrtIeKAQAASk74nxXrFDkivfyN1TlZMyHNM2GQqn2mmDQG7AHqx4ReYi9oK1UlupCGoa/s1XhzbbvGqxGDyV2PLvdtQy33bm2snuXibIXuMEwJz7VGQC5ITE27N8+oWDXisXsj4wi7xhCWAZW3szr1AQQORtxkWTxEpmZS5o47HuE+enQbDvCCmvgWW2GcxNK6Zez5dR6F0dL8Z6rmvgxjOqY4yN+P5rdJqSEPhAJ9E0fQCKifc7Sus/qpdt74qV0gWN8AC0yVYilllS25Uyw5As6Q7kakBJndiek8XccGxCmLL/l9y7rb82JZkeFJDdf1A1sd+xBoRUx7zn+PH9BzXW1kR6w9Sbvly3ZGLvzPpQ==; bm_sv=3D1E40EB57F82B3FACC32F3C480EF7AE~YAAQDDPFF1j3VZWKAQAAQ9YIoBW/Wt7Bgmq2Y+ULTvubu3zjNxPO+Ebi9dgBe3CCTTCpymH+M/nFGWKAdPcYVQwTL72GcQYM6Vj8e0Cht3XV2cG5i2U9l9m1NvD+r2QpUVXP+hLFbsVqDi8QDi8n884sCu6R3HkZdL5JbwWhjEvwYOs0WRGbv2OJuhQ1s4v90NkCbqLkYB7R5MJH2NYnwxIwh6uZ6Bwl6sJr4ngQndzMW6Dj992IxTp+A6/f1w==~1; bm_sz=09800805C4B204001854BF27EC215254~YAAQFTPFF3prtIeKAQAASk74nxUIgH2RclJqxytZK3Gh/v4lzevd2J0o1LrGaE/SswavaPeOuU+1NLUsdf7JxRJxZFUDidHT1rmKJDu7byuG8KNKO6fSUWfu6+hPf7r4DdPWcUYQ1uE7pTp7UEtHyBT0Bxi+EECS94B8T5qD4fqA6AwuRtyKDVv3naeMDFbkHTmme2iNwkZDdRSRvTTxYYbn3PxIC1K7sfnRuHdugWzm3kAG8qr2s2KK9x2iINZHNqsSI4nmvgYDJ70/SpnMrClDP/i/oLbZ2gOe8WTUT0Q=~3487287~4469825; hdnew=on; pe=p1; ADRUM_BT=R:0|g:03666fe4-d5fc-44ad-85d6-bff2ac086b0176844; aat1=off-p0; aat2=on; aat4=off-p2; acct_pe=p1; ccse=p1; fspe=p1; incap_ses_1467_2490223=The5LawrngwA3U6sUdVbFF4mBmUAAAAAobLP7RgrwVPHVU8peFuf1w==; incap_ses_444_2490223=/oVeEChuPkvKhRZIqGgpBjcmBmUAAAAAfiz0Ujf7JVnzh0OVBsOQDQ==; incap_ses_568_2490223=xuNdVMY0V2LfeEpgAvLhB2UmBmUAAAAAfV+33E9SFr7Vb6nVyrDwYg==; incap_ses_975_2490223=bLhqK7om2SoOC09pWuaHDXAkBmUAAAAAY2htVimT6UiVvF058r4sAA==; kcpe=e; mca1=on; mcpe=gr; mdpe=gr; mvpe=gr; nlbi_2490223_2556243=2zcHVbIJOVo0/78mQrA1IgAAAAAebUCcIzhjtzyImBp4F0Qf; rxe=i1; visid_incap_2490223=9QB+ShVGTWyyBgbUm25UeuQiBmUAAAAAQUIPAAAAAADv2/bRuBPCkkT4Yr7Bbqns"

    request.body = JSON.dump(cvs_base_query(ndc, zip_code, date))
    response = https.request(request)
    raise StandardError.new("Failed") unless response.kind_of? Net::HTTPSuccess 
    response.read_body
  end

  def fetch_locations_for_cvs(address, date)
    zip_code, state = address
    responses = {}
    CVS_NDC_DATA.each do |data|
      data[:ndcInfo].each do |ndc_info|
        ndc = ndc_info[:ndc] 
        print("Fetching CVS locations for #{zip_code} on #{date.to_s}")
        result, successful = cached(["cvs", "locations", zip_code, date.to_s, ndc], data_type: :cvs_locations) do
          JSON.parse(cvs_query(ndc, zip_code, date))
        end
        puts("[#{successful ? "success" : "error"}]")
      end
    end
  end


  def fetch_locations_for_address(address, retailer:)
    if retailer == :cvs
      fetch_locations_for_cvs(address, Date.today)
    elsif retailer == :walgreens
      fetch_locations_for_walgreens(address)
    end
  end

  def cached(cache_keys, data_type:)
    cache_hit = true
    result = Cache.where(key: cache_keys.join("--")).first_or_create do |cache|
      cache_hit = false
      data = yield
      print("...")
      cache.value = JSON.dump(data)
      cache.data_type = data_type
      cache.save!
    end
    sleep(0.1) unless cache_hit
    [result, true]
  rescue StandardError => e
    [nil, false]
  end

  def zip_codes
    popular_zip_codes = ZIP_CODES_TO_USE_CSV.map do |row|
      row['zipcode'].rjust(5, '0')
    end
    ZIP_CODE_CSV.each_with_index do |row, index|
      next unless popular_zip_codes.include?(row['zipcode'])
      yield row['zipcode'], row['state_abbr'], row, index
    end
  end

  task vaccines: :environment do
    zip_codes do |zip_code, state_abbr, _, index|
      [:cvs, :walgreens].each do |retailer|
        print("(#{index} / #{ZIP_CODE_CSV.size}) ")
        fetch_locations_for_address([zip_code, state_abbr], retailer: retailer)
      end
    end
  end

  def fetch_locations_for_walgreens(address)
    zip_code, state_abbr = address
    loc = Geocoder.search("#{zip_code} #{state_abbr}").first
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
      print("Fetching walgreens locations for #{zip_code} on #{date}")
      result, successful = cached(["walgreens", "locations", zip_code, date], data_type: :walgreens_locations) do
        response = HTTParty.post(
          "https://www.walgreens.com/hcschedulersvc/svc/v8/immunizationLocations/timeslots",
          body: body.to_json,
          headers: {
            "X-XSRF-TOKEN": XSRF_TOKEN,
            "Cookie": COOKIE,
            "Accept": 'application/json',
            "Content-Type": 'application/json',
          },
        )
        raise StandardError.new(response.text) unless response.success?
        JSON.parse(response.body)
      end
      if successful
        puts("[success]")
      else
        puts("[error]")
      end
    end
  end

  task count: :environment do
    by_zip_code_by_type = calculate_walgreens
    puts(by_zip_code_by_type)
  end

  def calculate_walgreens
    by_zip_code_by_type = {}
    already_seen_location = {}
    Cache.walgreens_locations.each do |cache|
      JSON.load(cache.value)['locations'].each do |location|
        next if already_seen_location[location['storenumber']]
        already_seen_location[location['storenumber']] = true

        zip_code = location['address']['zip']
        by_zip_code_by_type[zip_code] ||= {}

        location['appointmentAvailability'].each do |availability|
          availability['manufacturer'].each do |manufacturer|
            by_zip_code_by_type[zip_code][manufacturer['name']] ||= 0
            by_zip_code_by_type[zip_code][manufacturer['name']] += availability['numberOfSlotsAvailable']
          end
        end
      end
    end

    rows_data = []

    by_zip_code_by_type.each do |zip_code, types|
      types.each do |type, count|
        rows_data << {'state': ZIP_CODE_TO_STATE[zip_code], 'zip_code': zip_code, 'type': type, 'count': count, 'retailer': 'walgreens'}
      end
    end
    CSV.open("data.csv", "wb") do |csv|
      csv << rows_data.first.keys
      rows_data.each do |hash|
        csv << hash.values
      end
    end
  end
end