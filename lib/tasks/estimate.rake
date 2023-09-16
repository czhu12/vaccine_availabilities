require 'csv'
require "uri"
require "json"
require "net/http"

ZIP_CODE_CSV = CSV.parse(
  File.read(File.join('lib', 'assets', 'zip_codes.csv')),
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

namespace :estimate do
  def cvs_base_query(ndc, zip_code)
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
        "startDate": Date.today.to_s,
        "endDate": (Date.today + 7.day).to_s,
        "searchCriteria": {
          "addressLine": zip_code
        }
      }
    }
  end


  def cvs_query(ndc, zip_code)
    url = URI("https://www.cvs.com/Services/ICEAGPV1/immunization/3.0.0/getIMZStores")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Cookie"] = "_abck=52F4BACBA3E102872DF6FD740C1AF240~-1~YAAQFTPFF3hrtIeKAQAASk74nwqTnv8VmztmqHQ1cEhbJP094Cq6gu3CGstGTqtSpXb6laLfyrk5BQyRU4crQVVogJ0XL8b32RvWNQIHiIEEqqau45iNjcEY9BGt9XtYq7oEf5Dc9VFMFSzydR3lRNH4UVFnqTo5dl3PJDfGa9a5YuIQ5KFZG04ij/9FhdBw9lEtkGG7VPTF+G3MYgQ4PUD1ImXx3OmK53U+GgLd8Nncj6Yzxg17CRlsMe/GvJgJW082wbWqJugup9v0ulaMrk3Oscz4w0Z3VUse+WMyJXNoJdZ5nctL1dE+Cg3XrnRV61H3UTyBsUBHpj7DD31lRmJw7DjZ0HIj1e+iHWpYKV5DTecr208=~-1~-1~-1; ak_bmsc=94DE131E0B0D56BC4B1CFE2D9A54DB4D~000000000000000000000000000000~YAAQFTPFF3lrtIeKAQAASk74nxXrFDkivfyN1TlZMyHNM2GQqn2mmDQG7AHqx4ReYi9oK1UlupCGoa/s1XhzbbvGqxGDyV2PLvdtQy33bm2snuXibIXuMEwJz7VGQC5ITE27N8+oWDXisXsj4wi7xhCWAZW3szr1AQQORtxkWTxEpmZS5o47HuE+enQbDvCCmvgWW2GcxNK6Zez5dR6F0dL8Z6rmvgxjOqY4yN+P5rdJqSEPhAJ9E0fQCKifc7Sus/qpdt74qV0gWN8AC0yVYilllS25Uyw5As6Q7kakBJndiek8XccGxCmLL/l9y7rb82JZkeFJDdf1A1sd+xBoRUx7zn+PH9BzXW1kR6w9Sbvly3ZGLvzPpQ==; bm_sv=3D1E40EB57F82B3FACC32F3C480EF7AE~YAAQDDPFF1j3VZWKAQAAQ9YIoBW/Wt7Bgmq2Y+ULTvubu3zjNxPO+Ebi9dgBe3CCTTCpymH+M/nFGWKAdPcYVQwTL72GcQYM6Vj8e0Cht3XV2cG5i2U9l9m1NvD+r2QpUVXP+hLFbsVqDi8QDi8n884sCu6R3HkZdL5JbwWhjEvwYOs0WRGbv2OJuhQ1s4v90NkCbqLkYB7R5MJH2NYnwxIwh6uZ6Bwl6sJr4ngQndzMW6Dj992IxTp+A6/f1w==~1; bm_sz=09800805C4B204001854BF27EC215254~YAAQFTPFF3prtIeKAQAASk74nxUIgH2RclJqxytZK3Gh/v4lzevd2J0o1LrGaE/SswavaPeOuU+1NLUsdf7JxRJxZFUDidHT1rmKJDu7byuG8KNKO6fSUWfu6+hPf7r4DdPWcUYQ1uE7pTp7UEtHyBT0Bxi+EECS94B8T5qD4fqA6AwuRtyKDVv3naeMDFbkHTmme2iNwkZDdRSRvTTxYYbn3PxIC1K7sfnRuHdugWzm3kAG8qr2s2KK9x2iINZHNqsSI4nmvgYDJ70/SpnMrClDP/i/oLbZ2gOe8WTUT0Q=~3487287~4469825; hdnew=on; pe=p1; ADRUM_BT=R:0|g:03666fe4-d5fc-44ad-85d6-bff2ac086b0176844; aat1=off-p0; aat2=on; aat4=off-p2; acct_pe=p1; ccse=p1; fspe=p1; incap_ses_1467_2490223=The5LawrngwA3U6sUdVbFF4mBmUAAAAAobLP7RgrwVPHVU8peFuf1w==; incap_ses_444_2490223=/oVeEChuPkvKhRZIqGgpBjcmBmUAAAAAfiz0Ujf7JVnzh0OVBsOQDQ==; incap_ses_568_2490223=xuNdVMY0V2LfeEpgAvLhB2UmBmUAAAAAfV+33E9SFr7Vb6nVyrDwYg==; incap_ses_975_2490223=bLhqK7om2SoOC09pWuaHDXAkBmUAAAAAY2htVimT6UiVvF058r4sAA==; kcpe=e; mca1=on; mcpe=gr; mdpe=gr; mvpe=gr; nlbi_2490223_2556243=2zcHVbIJOVo0/78mQrA1IgAAAAAebUCcIzhjtzyImBp4F0Qf; rxe=i1; visid_incap_2490223=9QB+ShVGTWyyBgbUm25UeuQiBmUAAAAAQUIPAAAAAADv2/bRuBPCkkT4Yr7Bbqns"

    request.body = JSON.dump(cvs_base_query(ndc, zip_code))
    response = https.request(request)
    response.read_body
  end

  def cvs_fetch(zip_code)
    responses = {}
    CVS_NDC_DATA.each do |data|
      data[:ndcInfo].each do |ndc_info|
        responses[ndc_info[:ndc]] = JSON.parse(
          cvs_query(ndc_info[:ndc], zip_code)
        )
      end
    end
    responses
  end


  def fetch_locations_for_address(address, retailer:)
    if retailer == :cvs
      cvs_fetch(address)
    elsif retailer == :walgreens
      
    end
  end

  def cached(cache_keys, data_type:)
    Cache.where(key: cache_keys.join("-")).first_or_create do |cache|
      data = yield
      cache.value = JSON.dump(data)
      cache.data_type = data_type
      cache.save!
    end
  end

  def zip_codes
    ZIP_CODE_CSV.map do |row|
      row['zipcode']
    end
  end

  task vaccines: :environment do
    zip_codes.each do |zip_code|
      [:cvs, :walgreens].each do |retailer|
        locations = cached([zip_code, retailer], data_type: :search) do
          fetch_locations_for_address(zip_code, retailer: retailer)
        end
      end
    end
  end

  task vaccine_test: :environment do
    locations = cached(['95014', :cvs], data_type: :search) do
      fetch_locations_for_address('95014', retailer: :cvs)
    end 
  end
end