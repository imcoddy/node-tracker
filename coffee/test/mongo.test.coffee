APP_CONFIG = require('../config')

app = require('../mongo')
assert = require('assert')
query = {}
delay = (ms, func) -> setTimeout func, ms

module.exports = 
  'setup':()->
    console.log 'setup'
    app.open
      dbName: APP_CONFIG.DATABASE.DB_NAME
      
  'test buildFindQuery':()->
    console.log 'test buildFindQuery' 
    query = {};
    DEFAULT_QUERY_LIMIT = 20; 
    DEFAULT_QUERY_SKIP = 0;  		
    query= app.buildFindQuery();
    assert.eql({},query.query);
    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
    assert.eql(DEFAULT_QUERY_SKIP,query.skip);  
    assert.eql({},query.sort);
    assert.eql({},query.fields);
    
    query= app.buildFindQuery({});
    assert.eql({},query.query);
    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
    assert.eql({},query.sort);
    assert.eql({},query.fields);
  
    query = app.buildFindQuery({fields:{uid:1,time:1}});
    assert.eql({},query.query);
    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
    assert.eql({},query.sort);
    assert.eql({uid:1,time:1},query.fields);

    query = app.buildFindQuery({limit:1});
    assert.eql({},query.query);
    assert.eql(1,query.limit);   		
    assert.eql({},query.sort);
    assert.eql({},query.fields);

    query = app.buildFindQuery({limit:'1'});
    assert.eql({},query.query);
    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
    assert.eql({},query.sort);
    assert.eql({},query.fields);

    query = app.buildFindQuery({skip:1});
    assert.eql({},query.query);
    assert.eql(1,query.skip);   		
    assert.eql({},query.sort);
    assert.eql({},query.fields);

    query = app.buildFindQuery({sort:{uid:1}});
    assert.eql({},query.query);
    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
    assert.eql({uid:1},query.sort);
    assert.eql({},query.fields);

    query = app.buildFindQuery({query:{},fields:{uid:1,time:1}});
    assert.eql({},query.query);
    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
    assert.eql({},query.sort);
    assert.eql({uid:1,time:1},query.fields);	

    query = app.buildFindQuery({query:{},fields:{uid:1,time:1}});
    assert.eql({},query.query);
    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
    assert.eql({},query.sort);
    assert.eql({uid:1,time:1},query.fields);   
  
    query = app.buildFindQuery({query:{uid:{$exists:1}},fields:{uid:1,time:1}});
    assert.eql({uid:{$exists:1}},query.query);
    assert.eql(DEFAULT_QUERY_LIMIT,query.limit);   		
    assert.eql({},query.sort);
    assert.eql({uid:1,time:1},query.fields);   
    
    query = app.buildFindQuery({tag:{uid:1,time:1}});
    assert.eql({tag:{uid:1,time:1}},query.query);
    
    app.buildFindQuery {tag:'login',uid:'123456'}, (query)->
      assert.eql({tag:'login',uid:'123456'},query.query)
  
  'test count':()->
    app.open
      dbName: APP_CONFIG.DATABASE.DB_NAME,()->    
        console.log 'test count'
        query = {};  
        collection = 'test'
        app.remove collection, ->
          app.count(collection,query,(result)->assert.eql(0,result))
        
        app.count('apps',{},(result)->assert.eql(2,result))
        
        collection = 'records'
        app.count(collection,query,(result)->assert.eql(9,result))
        
        query = {tag:'login'}
        app.count(collection,query,(result)->assert.eql(7,result))
        
        query = {tag:'register'}
        app.count(collection,query,(result)->assert.eql(2,result))
        
        query = {tag:'Login'}
        app.count(collection,query,(result)->assert.eql(0,result))        
     
        console.log 'test find'
        query = {}
        collection ='records'
        app.find(collection,query, (result)->assert.length(result,9))
        
        query = {query:{tag:'login'}}
        app.find(collection,query, (result)->assert.length(result,7))
        
        query = {query:{app_id:'facebook_valley'}}
        app.find(collection,query, (result)->assert.length(result,1))
        
        query = {query:{tag:'login',app_id:'facebook_valley'}}
        app.find(collection,query, (result)->assert.length(result,1))
        
        query = {query:{tag:'login', app_id:'xiaonei_valley'}}
        app.find(collection,query, (result)->assert.length(result,6))
                
        query = {query:{app_id:'NO_SUCH_ID'}}
        app.find(collection,query, (result)->assert.length(result,0))
        
        console.log 'test find one'
        collection ='records'
        query={}
        app.findOne collection,query, (result)->assert.length(result,1)
        
        query={app_id:'facebook_valley'}
        app.findOne collection,query, (result)->
          assert.length(result,1)
          assert.eql 'facebook_valley',result[0].app_id          
        
        console.log 'test distinct'
        collection = 'apps'
        field = 'platform'
        query = {}        
        app.distinct collection, field, query, (result)->
          assert.length(result,2)
          assert.includes result,'facebook'
          assert.includes result,'xiaonei'
        
        collection = 'records'
        field = 'uid'
        query = {}        
        app.distinct collection, field, query, (result)->
          assert.length(result,7)       
          
                  
        console.log 'test save'
        collection = 'test'
        query = {}
        app.count collection,query,(count)->
          doc = 
            name:1
            value :2
          app.save collection,doc,()-> 
            console.log 'save in '+collection
            app.count collection,query,(result)->
              assert.eql count+1,result
        
#  'test save':()->
#    app.open
#      dbName: APP_CONFIG.DATABASE.DB_NAME,()->    
#        
#              app.close(); 
  
  'test teardown':()->
    delay 1000,->app.close()

