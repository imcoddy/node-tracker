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
  @db.open (err, db) -> 
    if err
      console.error(err.stack)
      throw err
    @db = db;
    if 'function' is typeof callback
      callback(db) 
    else
      return this;

###
Close database
###
data.db.close = (callback)->
  util.log 'Close database'
  if data.db.db 
    data.db.db.close (err, callback)->
      console.log 'Closing'
      if err
        console.error(err.stack)
        throw err
      if 'function' is typeof callback then callback()  

###
Check if the database is closed or not
###
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

###
Common operation for collections
###  
data.db.collectionOperation = (collection, operation, query, callback) ->
  @db.collection collection, (err, collection) ->
    if err
      console.error(err.stack)
      throw err
      
    collection[operation] query, (err, result) ->
      if err
        console.error(err.stack)
        throw err
      if 'function' is typeof callback then callback(result) else return result      

###
A util to build the query for finding, The format of query is as follow:
please put the original query in q.query
avoid using limit, fields, skip and sort as property of q
###
data.db.buildFindQuery = (q, callback) ->  
  q ?= {}
  query = {}

  if not q.limit? or 'number' isnt typeof q.limit 
    query.limit = APP_CONFIG.QUERY_DEFAULT_LIMIT;
  else 
    query.limit = q.limit;  

  query.fields = q.fields || {};
  query.skip = q.skip || 0;
  query.sort = q.sort || {};
  
  QUERY_PROPERTIES = ['limit','fields','skip','sort']
  for i in QUERY_PROPERTIES 
    delete q[i] if q[i]?

  if q.query?
    query.query = q.query
  else
    query.query = q
    
  if ('function' is typeof callback) then callback(query) else return query;
  
###
Count in a collection
###
data.db.count = (collection, query, callback) -> 
  data.db.collectionOperation(collection, 'count', query, callback)

###
Return an array of distinct value according to the query
@collection
@field which field to distinct on
@query query to limit the result
@callback
###
data.db.distinct = (collection, field, query, callback) ->
  query ?={};
  @db.collection collection, (err, collection) ->
    if err
      console.error(err.stack)
      throw err 

    collection.distinct field, query, (err, result)-> 
      if err
        console.error(err.stack)
        throw err 
      if ('function' is typeof callback) then callback(result) else return result

###
Find in a collection, note that the queryArgs should follow some rules
@queryArgs arguments for finding. 
###
data.db.find = (collection, queryArgs, callback) ->
  @buildFindQuery queryArgs,(query)->
#      console.info query;
      @db.collection collection, (err, collection) ->
        if (err) 
          console.error(err.stack)
          throw err 

        collection.find query.query, query.field, query.skip, query.limit, (err, cursor) -> 
          if (err) 
            console.error(err.stack)
            throw err 

          if (query.sort) 
            cursor = cursor.sort(query.sort)
          if ('function' is typeof callback) 
            data.onFindCursor(err, cursor, callback)
          else 
            return data.onFindCursor(err, cursor);

###
Find the first record in collection
###
data.db.findOne = (collection, query, callback)->
  query ?={};
  query.limit = 1;
  data.db.find(collection, query, callback);

###
On find cursor return
###
data.onFindCursor = (err, cursor, callback) ->
  if (err)
    console.error(err.stack)
    throw err 

  if ('function' is typeof callback) 
    cursor.toArray (err, items)-> 
      if (err) 
        console.error(err.stack)
        throw err 
      callback(items);
  else return cursor.toArray();
  
#todo
#data.db.findAndModify (collection, query, callback) ->
#  data.db.collectionOperation(collection, 'findAndModify', query, callback);




