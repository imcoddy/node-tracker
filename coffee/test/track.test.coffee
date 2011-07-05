APP_CONFIG = require('../config')

app = require('../track')
assert = require('assert')
query = {}
delay = (ms, func) -> setTimeout func, ms

module.exports = 
#  'setup':()->
#    console.log 'setup'
#    app.open
#      dbName: APP_CONFIG.DATABASE.DB_NAME
      
#  'test handleRequest':()->
#    console.log 'test buildFindQuery' 
#    query = {};
#    DEFAULT_QUERY_LIMIT = 20; 
#    DEFAULT_QUERY_SKIP = 0;  		
#    query= app.buildFindQuery();
#    assert.eql({},query.query);
#    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
#    assert.eql(DEFAULT_QUERY_SKIP,query.skip);  
#    assert.eql({},query.sort);
#    assert.eql({},query.fields);
   
#  'test getAllAppIDs':()->
#    console.log 'test getAllAppIDs'
#    app.getAllAppIDs (result)->
#      assert.length result,2
#      assert.eql result,['xiaonei_valley','facebook_valley'];
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
        headers 
          'user-agent':1
        
      record = app.wrapRecord(record, req);
      console.log record

  'test getAllAppIDs':()->
    app.openDB ()->
      console.log 'test getAllAppIDs'     
      app.getAllAppIDs (result)->
        console.log 'getAllAppIDs result'
        console.log result

#        app.distinct collection, field, query, (result)->
#          assert.length(result,2)
#          assert.includes result,'facebook'
#          assert.includes result,'xiaonei'
#        
#        collection = 'records'
#        field = 'uid'
#        query = {}        
#        app.distinct collection, field, query, (result)->
#          assert.length(result,7)       
#          
#                  
#        console.log 'test save'
#        collection = 'test'
#        query = {}
#        app.count collection,query,(count)->
#          doc = 
#            name:1
#            value :2
#          app.save collection,doc,()-> 
#            console.log 'save in '+collection
#            app.count collection,query,(result)->
#              assert.eql count+1,result
#        
#  'test save':()->
#    app.open
#      dbName: APP_CONFIG.DATABASE.DB_NAME,()->    
#        
#              app.close(); 
  
  'test teardown':()->
    console.log app
    delay 1000,->app.closeDB()

