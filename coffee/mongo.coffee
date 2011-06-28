mongo = require('mongodb');
util = require('util');
APP_CONFIG = require('./config');
data = data || {};

data.db = exports;
data.db.server = APP_CONFIG.DATABASE.SERVER;
data.db.port = APP_CONFIG.DATABASE.PORT;
data.db.db = null;
data.db.dbName = '';
data.db.collection = '';

data.db.open = (mongoInfo, callback) -> 
	util.log('Open database');
	@dbName = mongoInfo.dbName;
	@db = new mongo.Db(mongoInfo.dbName, new mongo.Server(data.db.server, data.db.port, {}), {}) if !@db
	@db.open( (err, db) -> 
		console.error(err.stack) if err
		@db = db;
		callback(db) if 'function' is typeof callback;
	);
	return this;

data.db.close = ()->
  data.db.db.close() if data.db.db
  
data.db.save = (collection, doc, callback) -> 
	data.db.collectionOperation(collection, 'save', doc, callback);

data.db.collectionOperation = (collection, operation, query, callback) ->
	this.db.collection(collection, (err, collection) ->
    console.error(err.stack) if err
		collection[operation](query, (err, result) ->
			if err
			  console.error(err.stack)
			if 'function' is typeof callback then callback(result) else return result			
		)
	)

data.db.buildFindQuery = (q, callback) ->	
	q = {} if not q?
	
	query = q if q?
	
	if !query.query
		query = 
			query: {},
		
	
	if q.limit is undefined or 'number' isnt typeof q.limit 
    query.limit = APP_CONFIG.QUERY_DEFAULT_LIMIT;
  else 
    query.limit = q.limit;	

	query.fields = q.fields || {};
	query.skip = q.skip || 0;
	query.sort = q.sort || {};

	if ('function' is typeof callback) then callback(query) else return query;



