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

###
Open database
@mongoInfo 
@callback
###
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

data.db.close = (callback)->
  util.log 'Close database'
  if data.db.db 
    data.db.db.close (err, callback)->
      console.log 'Closing'
      if err
        console.error(err.stack)
			if 'function' is typeof callback then callback()  

data.db.isClosed = ()->
  not data.db.db

###
Save a document into the collection specified
###  
data.db.save = (collection, doc, callback) -> 
	data.db.collectionOperation(collection, 'save', doc, callback);

###
Remove all documents in the collection specified
###  
data.db.remove = (collection, callback) -> 
	data.db.collectionOperation(collection, 'remove', callback);
	
data.db.collectionOperation = (collection, operation, query, callback) ->
  @db.collection collection, (err, collection) ->
    console.error(err.stack) if err
    collection[operation] query, (err, result) ->
	    if err
	      console.error(err.stack)
	    if 'function' is typeof callback then callback(result) else return result			

data.db.buildFindQuery = (q, callback) ->	
	q = {} if not q?
	
	query = q if q?
	
	if !query.query
		query = 
			query: {}		
	
	if not q.limit? or 'number' isnt typeof q.limit 
    query.limit = APP_CONFIG.QUERY_DEFAULT_LIMIT;
  else 
    query.limit = q.limit;	

	query.fields = q.fields || {};
	query.skip = q.skip || 0;
	query.sort = q.sort || {};

	if ('function' is typeof callback) then callback(query) else return query;

data.db.count = (collection, query, callback) -> 
  data.db.collectionOperation(collection, 'count', query, callback)



data.db.distinct = (collection, field, query, callback) ->
	this.db.collection(collection, (err, collection) ->
		console.error(err.stack) if err 

		collection.distinct(field, query, (err, result)-> 
			console.error(err.stack) if err 
			if ('function' is typeof callback) then callback(result) else return result
		);
	);

data.db.find = (collection, queryArgs, callback) ->
	this.db.collection(collection, (err, collection) ->
		if (err) 
			console.error(err.stack)

		collection.find(queryArgs.query, queryArgs.field, queryArgs.skip, queryArgs.limit, (err, cursor) -> 
			if (err) 
				console.error(err.stack)

			if (queryArgs.sort) 
			  cursor = cursor.sort(queryArgs.sort)
			if ('function' is typeof callback) 
			  data.onFindCursor(err, cursor, callback)
			else 
			  return data.onFindCursor(err, cursor);
		);
	);


data.db.findOne = (collection, query, callback)->
	query.limit = 1;
	this.find(collection, query, callback);


data.onFindCursor = (err, cursor, callback) ->
	if (err)
		console.error(err.stack);

	if ('function' is typeof callback) 
		cursor.toArray (err, items)-> 
			if (err) 
				console.error(err.stack);
			
			callback(items);

	else return cursor.toArray();




