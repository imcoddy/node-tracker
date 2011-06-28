APP_CONFIG = require('../config')

app = require('../mongo')
assert = require('assert')


module.exports = 
  'test buildFindQuery':()->
    query
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
  
#  'test count':()->
#    query

#  'test open':()->
#    app.close()
#    assert.equal true,app.isClosed()
#    app.open
#    	dbName: APP_CONFIG.DATABASE.DB_NAME,
#    assert.equal false,app.isClosed()
#    app.close()
#    assert.equal true,app.isClosed()


