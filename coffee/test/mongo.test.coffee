APP_CONFIG = require('../config')

app = require('../mongo')
assert = require('assert')
query = {}

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
  
  'test count':()->
    app.open
      dbName: APP_CONFIG.DATABASE.DB_NAME,()->    
        console.log 'test count'
        query = {};  
        collection = 'test'
        app.count(collection,query,(result)->assert.eql(0,result))
        
        collection = 'records'
        app.count(collection,query,(result)->assert.eql(9,result))
        
        query = {tag:'login'}
        app.count(collection,query,(result)->assert.eql(7,result))
        
        query = {tag:'register'}
        app.count(collection,query,(result)->assert.eql(2,result))
        
        query = {tag:'Login'}
        app.count(collection,query,(result)->assert.eql(0,result))
        
        
        app.close();


