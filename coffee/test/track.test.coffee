APP_CONFIG = require('../config')

app = require('../track')
assert = require('assert')
query = {}
delay = (ms, func) -> setTimeout func, ms

module.exports = 
  'test checkRecord':()->
    console.log 'test checkRecord' 
    record = 
      app_name: 'app'
      platform: 'platform'
      tag:'tag'
      
    assert.eql(true,app.checkRecord(record))

    record = 
      app_name: 'app'
      platform: 'platform'
      
    assert.eql(false,app.checkRecord(record))
    
    record = 
      platform: 'platform'
      tag:'tag'
      
    assert.eql(false,app.checkRecord(record))   

  'test wrapRecord':()->
    app.openDB ()->
      console.log 'test wrapRecord'     
      record = 
        app_name: 'app'
        platform: 'platform'
        tag:'tag'
        
      req = 
        headers :
          'user-agent':1
        connection:
          remoteAddress:2
        
      record = app.wrapRecord(record, req);

#  'test getAllAppIDs':()->
#    app.openDB ()->
#      console.log 'test getAllAppIDs'     
#      app.getAllAppIDs (result)->
#        console.log 'getAllAppIDs result'
#        assert.length(result, 2)
#        console.log result
#        assert.includes result, 'xiaonei_valley'
  
  'test teardown':()->
    console.log 'Closing'
    delay 1000,->app.closeDB()

