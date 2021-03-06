# mocha basics.coffee --compilers coffee:coffee-script/register --timeout 30000

selenium = require "selenium-webdriver"
chai = require 'chai'
chai.use require 'chai-as-promised'
expect = chai.expect

before ->
  @timeout = 8000
  global.driver = new selenium.Builder().withCapabilities(selenium.Capabilities.chrome()).build()
  global.url = "http://localhost/git/rapidtargets"
  #global.url = "http://www.rapidtargets.com"
  global.timeout = 30000
  driver.getWindowHandle()
  driver.get url
  driver.findElement(id: 'exampleInputEmail1').sendKeys 'TDD'
  driver.findElement(id: 'exampleInputPassword1').sendKeys 'PASSWORD'
  driver.findElement(xpath: "//button[@type='submit']").click()
  driver.wait (->
    driver.isElementPresent(linkText: 'Admin')
  ), 30000, '\nFailed to load Welcome page.'
  driver.sleep 1000

###
after ->
  driver.quit()
###

describe 'Reset TDD Rapidtargets data', ->
  it "Reset TDD supplier", ->
    driver.get url + "/#/test/"
    driver.sleep 500
    driver.findElement(id: "resetBtn").click()
    driver.wait ( ->
      driver.isElementPresent(id: 'successmsg')
    ), timeout, '\nFailed to reset data.'

describe "Checking Group's", ->
  it "Create a group", ->
    driver.get url + "#/groups"
    driver.sleep 500
    driver.findElement(linkText: "Create Group").click()
    driver.sleep 500
    driver.findElement(id: "name").sendKeys "Joburg reps"
    driver.findElement(id: "Owner").sendKeys "Shaun"
    driver.findElement(id: "Tel").sendKeys "082 121 1211"
    driver.findElement(id: "Area").sendKeys "Joburg"
    driver.findElement(linkText: "Save").click()
    driver.sleep 3000
    waitFor(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']", "\nFailed to create group")

  it "Goto members", ->
    driver.get url + "#/groups"
    waitFor(xpath: "//a/div[contains(.,'Joburg')]","Could not find Joburg reps")
    driver.findElement(xpath: "//a/div[contains(.,'Joburg')]").click()
    waitFor(linkText: "Members","Could not find members link")
    driver.sleep 5000
    driver.findElement(linkText: "Members").click()
    waitFor(linkText: "Invite people to your group","Could not find invite link")

  it "Invite popup", ->
    driver.findElement(linkText: "Invite people to your group").click()
    waitFor(id: "UserID","could not find popup")
    driver.findElement(id: "UserID").sendKeys "TDD2"
    driver.findElement(xpath: "//button[@class='btn btn-success ng-binding']").click()
    waitFor(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']", "\nFailed to invite user")
    driver.findElement(xpath: "//div[@class='modal-footer']/button[@class='btn btn-default']").click()
    driver.sleep 500
    driver.isElementPresent(xpath: "//a[div/div='TDD Rep 2']")

  it "Dashbord message", ->
    driver.get url + "#/groups"
    driver.sleep 500
    driver.findElement(xpath: "//div[span[@class='fa fa-comment-o']]").click()
    driver.sleep 500
    driver.findElement(xpath: "//textarea").sendKeys "hello world"
    driver.findElement(xpath: "//button[@class='btn btn-success']").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//div[contains(text(),'hello world')]")
      ), timeout, "\nFailed to create message"

describe "Companies", ->
    it "Create a new company and set displayfields", ->
        driver.get url + "#/myterritory"
        driver.findElement(linkText: "Company").click()
        driver.sleep 500
        driver.findElement(id: "settingBtn").click()
        driver.sleep 2000
        driver.findElement(xpath: "//th[4]").click()
        driver.sleep 500
        #unclick all display fields
        deselectDF 2
        deselectDF 3
        deselectDF 4
        deselectDF 5
        deselectDF 6
        deselectDF 7
        selectDF "AccountID", "1", ""
        selectDF "Name", "2", ""
        selectDF "AccountGroup", "3", ""
        selectDF "Pricelist", "4", ""
        driver.findElement(id: "saveBtn").click()
        waitFor(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']","\nFailed to create message")

    it "Save the new customer", ->
        newcustomer("TDD3","Small Stores","TDD Customer 3","A")
        newcustomer("TDD2","Big Stores","TDD Customer 2","A")
        newcustomer("TDD1","Big Stores","TDD Customer 1","A")
        newcustomer("TDD4","Small Stores","TDD Customer 4","A")
        newcustomer("TDD5","Big Stores","TDD Customer 5","A")

describe "Contacts", ->
    it "Create contact 1 for TDD1", ->
        gocustomer("TDD Customer 1")
        driver.findElement(xpath: "//a[text()='Contacts']").click()
        driver.findElement(linkText: "Contact").click()
        driver.findElement(id: "Name").sendKeys "Peter Prinsloo"
        driver.findElement(id: "Email").sendKeys "peter@prinsloo.com"
        driver.findElement(id: "Mobile").sendKeys "082 121 1211"
        driver.findElement(id: "TEL").sendKeys "011 682 2122"
        driver.findElement(linkText: "Save").click()
        driver.wait (->
          driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']")
          ), 10000, "\nFailed to create contact"

    it "Create contact 2 for TDD1", ->
        gocustomer("TDD Customer 1")
        driver.findElement(xpath: "//a[text()='Contacts']").click()
        driver.findElement(linkText: "Contact").click()
        driver.findElement(id: "Name").sendKeys "Abigail Smith"
        driver.findElement(id: "Email").sendKeys "abi@prinsloo.com"
        driver.findElement(id: "Mobile").sendKeys "082 121 1211"
        driver.findElement(id: "TEL").sendKeys "011 682 2122"
        driver.findElement(linkText: "Save").click()
        driver.wait (->
          driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']")
          ), 10000, "\nFailed to create contact"

describe "Activities", ->
    it "Basic activity", ->
        gocustomer('TDD Customer 1')
        driver.findElement(xpath: "//button[@class='selectactivitytype']").click()
        driver.sleep 1000
        driver.findElement(xpath: "//a[p='Checkin']").click()
        driver.sleep 1000
        driver.findElement(id: "note").sendKeys "Peter was not in"
        driver.findElement(xpath: "//div[p='Buyer not in']").click()
        driver.findElement(linkText: "Save").click()
        driver.wait (->
          driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']")
          ), 10000, "\nCould not create activity"

    it "Pipeline activity and RapidSales opportunity", ->
        gocustomer('TDD Customer 1')
        driver.findElement(xpath: "//button[@class='selectactivitytype']").click()
        driver.sleep 500
        driver.findElement(xpath: "//a[p='First Meeting'][1]").click()
        driver.sleep 500
        driver.findElement(id: "note").sendKeys "Looks like a good company"
        driver.findElement(id: "newBtn").click()
        driver.sleep 500
        driver.findElement(id: "upfrontFee").clear()
        driver.findElement(id: "monthlyFee").clear()
        driver.findElement(id: "closeByDate").clear()
        driver.findElement(id: "name").sendKeys "Rapid Sales"
        driver.findElement(id: "description").sendKeys "Rapidsales opportunity"
        driver.findElement(id: "upfrontFee").sendKeys "1000"
        driver.findElement(id: "monthlyFee").sendKeys "100"
        driver.findElement(id: "closeByDate").sendKeys "January 1, 2018"
        driver.findElement(linkText: "Save").click()
        waitFor(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']", "\nCould not create opportunity")

    it "Check activity details are remembered and save the activity", ->
        driver.sleep 4000
        driver.findElement(id: "Opportunity").getAttribute("value").then (opp)->
            expect(opp).to.not.equal("")
        driver.findElement(id: "contacts").sendKeys "a"
        driver.findElement(linkText: "Save").click()
        waitFor(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']", "\nCould not create activity")
        driver.sleep 4000

    it "Check percentage", ->
        driver.get url + "#/history/opportunities/TDD1"
        driver.sleep 1000
        driver.findElement(xpath: "//div[text()='Rapid Sales']/following-sibling::div[4]").getText().then (percent) ->
          expect(percent).to.be.equal("30%")

describe "Check Opportunities", ->
  it "Check listing in my territory", ->
    driver.get url + "#/myterritory"
    waitFor(linkText: "Opportunities", "No opportunities button")
    driver.findElement(linkText: "Opportunities").click()
    waitFor(xpath: "(//a[div/div[text()='Rapid Sales']])[1]", "Could not find opportunity")
    driver.findElement(xpath: "(//a[div/div[text()='Rapid Sales']])[1]").click()
    waitFor(id: "monthlyFee", "Opportunity detail screen did not appear")
    driver.findElement(id: "monthlyFee").getAttribute('value').then (amount) ->
      expect(amount).to.be.equal("100")

  it "Check opportunity activities", ->
    driver.sleep 500
    driver.findElement(linkText: "Activities").click()
    driver.isElementPresent(xpath: "//a[div/div[text()='Cold Call']]")

  it "Check for checkin activity does not appear", ->
    driver.findElement(xpath: "//button[@class='selectactivitytype fa fa-plus']").click()
    driver.isElementPresent(xpath: "//a[p[text()='Checkin']]").then (isPresent) ->
      expect(isPresent).to.be.false
      return

  it "Create pipeline activity" , ->
    driver.findElement(xpath: "//a[p[text()='First Meeting']]").click()
    driver.findElement(id: "note").sendKeys "First meeting went well"
    driver.findElement(id: "Opportunity").getAttribute('value').then (opp) ->
      expect(opp).to.not.equal("")
    driver.findElement(linkText: "Save").click()
    waitFor(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']", "\nCould not create activity")

describe "Check navigation in history", ->
    it "Check activities -> Activity -> activities" , ->
        gocustomer('TDD Customer 1')
        driver.findElement(linkText: "History").click()
        waitFor(xpath: "//div[text()='Checkin']","Activities did not display")
        driver.findElement(xpath: "//div[text()='Checkin']").click()
        driver.sleep 500
        driver.findElement(linkText: "Back").click()
        waitFor(xpath: "//div[text()='Checkin']","Navigation problem, Activities did not display after back from activity")

    it "Check opportunities -> activities -> NEW -> activities -> opportunities" , ->
        driver.sleep 500
        driver.findElement(xpath: "//button[@class='selectactivitytype']").click()
        driver.findElement(linkText: "Back").click()
        waitFor(xpath: "//div[text()='Checkin']","Navigation problem, Activities did not display after back from selectactivitytype")
        driver.findElement(xpath: "//button[@class='selectactivitytype']").click()
        driver.findElement(xpath: "//p[text()='First Meeting']").click()
        driver.findElement(linkText: "Back").click()
        waitFor(xpath: "//div[text()='Checkin']","Navigation problem, Activities did not display after back from NEW activity")

    it "Check opportunities -> opportunity -> activities -> opportunity -> opportunities" , ->
        gocustomer('TDD Customer 1')
        driver.findElement(linkText: "History").click()
        waitFor(xpath: "//div[text()='Checkin']","Activities did not display")
        driver.findElement(linkText: "Opportunities").click()
        waitFor(xpath: "//div[text()='Rapid Sales']","Rapid Sales Opportunity did not display")
        driver.findElement(xpath: "//div[text()='Rapid Sales']").click()
        waitFor(xpath: "//input[@id='name']", "Rapid Sales opportunity form did not display")
        driver.findElement(linkText: "Activities").click()

        driver.findElement(linkText: "Back").click()
        waitFor(xpath: "//div[text()='Rapid Sales']","Navigation problem, opportunities not displayed after clicking on back")

    it "Check opportunities -> opportunity -> activities -> activity -> activities -> opportunity -> opportunities" , ->
        driver.findElement(linkText: "Opportunities").click()
        waitFor(xpath: "//div[text()='Rapid Sales']","Rapid Sales Opportunity did not display")
        driver.findElement(xpath: "//div[text()='Rapid Sales']").click()
        waitFor(xpath: "//input[@id='name']", "Rapid Sales opportunity form did not display")
        driver.findElement(linkText: "Activities").click()
        waitFor(xpath: "//div[text()='First Meeting']", "Opportunity activities did not appear")
        driver.findElement(xpath:"//div[text()='First Meeting']").click()
        driver.findElement(linkText: "Back").click()
        waitFor(xpath: "//div[text()='First Meeting']", "Navigation problem, Activities not displayed after clicking on back")

    it "Check opportunities -> opportunity -> activities -> NEW -> activities -> opportunity -> opportunities" , ->
        driver.sleep 500
        driver.findElement(xpath: "//button[@class='selectactivitytype fa fa-plus']").click()
        driver.findElement(linkText: "Back").click()
        waitFor(xpath: "//div[text()='First Meeting']", "Navigation problem, Did not go back correctly from selectpipelineactivitytype to opportunity activities")
        driver.findElement(xpath: "//button[@class='selectactivitytype fa fa-plus']").click()
        driver.findElement(xpath: "//p[text()='First Meeting']").click()
        driver.findElement(linkText: "Back").click()
        waitFor(xpath: "//div[text()='First Meeting']", "Navigation problem, Did not go back correctly from newactivity to opportunity activities")

describe "Create call cycle", ->
  it "Get our week number", ->
    driver.get url + "#/today"
    driver.sleep 500
    driver.findElement(id: "weekn").getText().then (val) ->
      global.weekNumber = val
      return

  it "Goto the correct week", ->
    driver.findElement(linkText: "Edit").click()
    driver.sleep 500
    # Get to this week
    if global.weekNumber > 1
      driver.findElement(id: "nextBtn").click()
    if global.weekNumber > 2
      driver.findElement(id: "nextBtn").click()
    if global.weekNumber > 3
      driver.findElement(id: "nextBtn").click()
    driver.findElement(id: "weektext").getText().then (weekText) ->
      expect(weekText).to.be.equal("Week " + global.weekNumber)

  it "Add 1st customer and click today", ->
    driver.findElement(id: "searchbox").clear()
    driver.findElement(id: "searchbox").sendKeys "TDD"
    driver.sleep 500
    driver.findElement(xpath: "//li[a='TDD Customer 1']").click()
    driver.findElement(id: "addBtn").click()
    driver.sleep 500
    # calculate day of week, so we know which column to click on for today
    day = (new Date).getDay() + 3
    driver.findElement(xpath: "//table/tbody/tr/td[" + day + "]/span").click()

  it "Add 2nd customer, click today and save", ->
    driver.findElement(id: "searchbox").clear()
    driver.findElement(id: "searchbox").sendKeys "TDD"
    driver.sleep 500
    driver.findElement(xpath: "//li[a='TDD Customer 2']").click()
    driver.findElement(id: "addBtn").click()
    driver.sleep 500
    # calculate day of week, so we know which column to click on for today
    day = (new Date).getDay() + 3
    driver.findElement(xpath: "(//table/tbody/tr/td[" + day + "]/span)[2]").click()
    driver.findElement(linkText: "Save").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']")
      ), 10000, "\nCould not save the call cycle"

describe "Check Today Screen", ->
  it "Expect 2 customers on today screen", ->
    driver.get url + "#today"
    driver.sleep 500
    driver.isElementPresent(xpath: "//h4[text()='TDD Customer 2']")

  it "Create an activity and check customer is ticked", ->
    waitFor(xpath: "//a[h4[text()='TDD1']]", "Could not find Customer 1")
    driver.findElement(xpath: "//a[h4[text()='TDD2']]").click()
    waitFor(xpath: "//button[@class='selectactivitytype']", "Could not find + button")
    driver.findElement(xpath: "//button[@class='selectactivitytype']").click()
    waitFor(xpath: "//a[p[text()='Checkin']]", "Could not find checkin activity type")
    driver.findElement(xpath: "//a[p[text()='Checkin']]").click()
    driver.findElement(id: "note").sendKeys "Checking today screen"
    driver.findElement(linkText: "Save").click()
    waitFor(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']", "\nCould not create activity")
    driver.findElement(linkText: "Back").click()
    waitFor(xpath: "//ul/a",  "could not get back to today screen")
    driver.isElementPresent(xpath: "//a[1]/span[@class='fa fa-check-square-o pull-left']")

describe "Check Leaderboard", ->
  it "Ensure it has remembered our group", ->
    driver.get url + "#groups"
    driver.wait (->
      driver.isElementPresent(xpath: "//div[text()='Joburg reps']")
      ), timeout, "Did not remember our group"

  it "Check for 1 customer for TDD User on leaderboard", ->
    driver.findElement(linkText: "LeaderBoard").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//td[text()='1']")
      ), timeout, "Did not find the leaderboard with count of 1 customer under activities"


describe "Test highlighting of activities", ->
  it "Create activity", ->
    gocustomer('TDD Customer 2')
    driver.findElement(xpath: "//button[@class='selectactivitytype']").click()
    driver.sleep 500
    driver.findElement(xpath: "//a[p='Cold Call'][1]").click()
    driver.sleep 500
    driver.findElement(id: "note").sendKeys "Test highlights"
    driver.findElement(linkText: "Save").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']")
      ), 10000, "\nCould not save activity"
    driver.isElementPresent(xpath: "//a[@class='ng-scope list-group-item-success row list-group-item'][contains(.,'Cold Call')]")


describe "Day End's", ->
  it "Day End Procedures", ->
    driver.get url + "#dayend"
    driver.findElement(linkText: "Refresh").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//small[@class='ng-binding cal-events-num badge badge-important pull-left']")
      ), timeout, "Could not find day end results"
    # Select todays date eg. 11th
    d = (new Date).getDate()
    driver.findElement(xpath: "//div[span[@class='pull-right ng-binding']='" + d + "']").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//ul[@class='list-group inset']")
      ), timeout, "\nCould not select date"

  it "Check for error over 100%", ->
    driver.findElement(xpath:"(//input)[1]").sendKeys "110"
    driver.findElement(linkText: "Next").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-danger']")
      ), timeout, "Did not get over 100% error message"
    driver.sleep 4000

  it "Check Normal Percentage", ->
    driver.findElement(xpath:"(//input)[1]").clear()
    driver.findElement(xpath:"(//input)[1]").sendKeys "40"
    driver.findElement(linkText: "Next").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//h4[contains(.,'Other')]")
      ), timeout, "Did not get to next screen"

  it "Check for error over 100% error", ->
    driver.findElement(xpath: "(//input[@id='field'])[2]").sendKeys "400"
    driver.findElement(linkText: "Save").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-danger']")
      ), timeout, "Did not get over 100% error message"
    driver.sleep 4000
    driver.findElement(xpath: "(//input[@id='field'])[2]").clear()

  it "Check for error to enter Other details", ->
    driver.findElement(id: "Other").sendKeys "10"
    driver.findElement(linkText: "Save").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-danger']")
      ), timeout, "Did not get error to enter a description"
    driver.sleep 4000

  it "Checking less than 100% error", ->
    driver.findElement(xpath: "(//input[@id='field'])[2]").clear()
    driver.findElement(xpath: "(//input[@id='field'])[2]").sendKeys "30"
    driver.findElement(id: "Other").clear()
    driver.findElement(id: "Other").sendKeys "10"
    driver.findElement(id: "otherDescription").sendKeys "Doctor"
    driver.findElement(linkText: "Save").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-danger']")
      ), timeout, "Did not get error to enter a description"
    driver.sleep 4000

  it "Create total says 100%", ->
    driver.findElement(xpath: "(//input[@id='field'])[3]").sendKeys "20"
    driver.sleep 500
    driver.isElementPresent(xpath: "//td[contains(.,'100')]")

  it "Save the day end", ->
    driver.findElement(linkText: "Save").click()
    driver.wait (->
      driver.isElementPresent(xpath: "//div[@class='alert ng-scope top-right am-fade alert-success']")
      ), timeout, "\nCould not create activity"

  it "Check date is green", ->
    d = (new Date).getDate() # Get todays date eg. 11th
    driver.wait (->
      driver.findElement(xpath: "//div[span[@class='pull-right ng-binding']='" + d + "']/span/small[@class='ng-binding cal-events-num badge badge-green pull-left']")
      ), timeout, "\nCould not create activity"



#####################################################################################################
# call this function to unselect a displayfield
deselectDF = (cnt) ->
    driver.findElement(xpath: "//tr[" + cnt + "]/td[4]/input").getAttribute("checked").then (val) ->
        if val == "true"
            driver.findElement(xpath: "//tr[" + cnt + "]/td[4]/input").click()

# call this function to select a displayfield
selectDF = (field, order, label) ->
    driver.findElement(id: "visible" + field).click()
    driver.findElement(id: "sort" + field).click()
    driver.findElement(id: "sort" + field).clear()
    driver.findElement(id: "sort" + field).sendKeys order
    if label != ""
        driver.findElement(id: "label" + field).clear()
        driver.findElement(id: "label" + field).sendKeys label

# call this method to go into my territory and search for/select a customer
gocustomer = (custname) ->
    driver.get url + "#/myterritory"
    driver.sleep 500
    driver.findElement(linkText: "Companies").click()
    driver.findElement(xpath: "//a[div[text()='" + custname + "']]").click()
    waitFor(id: "Name","Could not find the customer ")

# Create a new customer
newcustomer = (AccountID,AccountGroup,AccountName,Pricelist) ->
    driver.get url + "#/myterritory"
    driver.findElement(linkText: "Company").click()
    driver.sleep 1000
    driver.findElement(id: "AccountID").sendKeys AccountID
    driver.findElement(id: "AccountGroup").sendKeys AccountGroup
    driver.findElement(id: "Name").sendKeys AccountName
    driver.findElement(id: "Pricelist").clear()
    driver.findElement(id: "Pricelist").sendKeys Pricelist
    driver.findElement(linkText: "Save").click()
    waitFor(id: "searchBox","\nFailed to create company")

# Wait for element
waitFor = (obj, message) ->
    driver.wait (->
      driver.isElementPresent(obj)
      ), 30000, "\n" + message

###
# take a snapshot
###
screenshot = (step) ->
    driver.takeScreenshot().then (image, err) ->
        require('fs').writeFile 'out.png', image, 'base64', (err) ->
            console.log err
            return
        return
