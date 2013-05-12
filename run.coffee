request = require 'request'
faker = require 'Faker'
fs = require 'fs'
async = require 'async'

{join} = require 'path'

numberToSpam = 10
folderToSaveTo = "./vouchers"

urlToSpam = "http://fly.aa.com/klout/api/entry/"
rewardUrl = "http://fly.aa.com/klout/api/reward/"

randScore = -> Math.floor(Math.random()*(65-55+1)+55)
generateUser = ->
  out =
    KloutScore: randScore()
    KloutID: faker.Internet.userName()
    FirstName: faker.Name.firstName()
    LastName: faker.Name.lastName()
    EmailAddress: faker.Internet.email()
    AADV: ""
    EnterSweepstakes: true
  return out

getVoucher = (num, done) ->
  console.log "Getting voucher #{num}..."
  user = generateUser()
  opt =
    method: "POST"
    url: urlToSpam
    json: user
  request opt, (err, res, body) ->
    return done err if err?
    console.log body
    return done "No body" unless body? and body.Reward?
    id = body.ID
    fs.writeFile join(folderToSaveTo, "#{body.ID}-#{user.KloutID}.json"), JSON.stringify(body, null, 4), (err) ->
      return done err if err?
      thePdf = fs.createWriteStream join(folderToSaveTo, "#{body.ID}-#{user.KloutID}.pdf")
      request("#{rewardUrl}#{user.KloutID}").pipe thePdf
      done()

try
  fs.mkdirSync folderToSaveTo

async.forEachSeries [1..numberToSpam], getVoucher, (err) ->
  return console.log err if err?
  console.log "Done!"