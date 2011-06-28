(function() {
  var APP_CONFIG, data, mongo, util;
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
  data.db.open = function(mongoInfo, callback) {
    util.log('Open database');
    this.dbName = mongoInfo.dbName;
    if (!this.db) {
      this.db = new mongo.Db(mongoInfo.dbName, new mongo.Server(data.db.server, data.db.port, {}), {});
    }
    this.db.open(function(err, db) {
      if (err) {
        console.error(err.stack);
      }
      this.db = db;
      if ('function' === typeof callback) {
        return callback(db);
      }
    });
    return this;
  };
  data.db.close = function() {
    if (data.db.db) {
      return data.db.db.close();
    }
  };
  data.db.save = function(collection, doc, callback) {
    return data.db.collectionOperation(collection, 'save', doc, callback);
  };
  data.db.collectionOperation = function(collection, operation, query, callback) {
    return this.db.collection(collection, function(err, collection) {
      if (err) {
        return console.error(err.stack);
      }
    }, collection[operation](query, function(err, result) {
      if (err) {
        console.error(err.stack);
      }
      if ('function' === typeof callback) {
        return callback(result);
      } else {
        return result;
      }
    }));
  };
  data.db.buildFindQuery = function(q, callback) {
    var query;
    if (!(q != null)) {
      q = {};
    }
    if (q != null) {
      query = q;
    }
    if (!query.query) {
      query = {
        query: {}
      };
    }
    if (!(q.limit != null) || 'number' !== typeof q.limit) {
      query.limit = APP_CONFIG.QUERY_DEFAULT_LIMIT;
    } else {
      query.limit = q.limit;
    }
    query.fields = q.fields || {};
    query.skip = q.skip || 0;
    query.sort = q.sort || {};
    if ('function' === typeof callback) {
      return callback(query);
    } else {
      return query;
    }
  };
  data.db.count = function(collection, query, callback) {
    return data.db.collectionOperation(collection, 'count', query, callback);
  };
  data.db.distinct = function(collection, field, query, callback) {
    return this.db.collection(collection, function(err, collection) {
      if (err) {
        console.error(err.stack);
      }
      return collection.distinct(field, query, function(err, result) {
        if (err) {
          console.error(err.stack);
        }
        if ('function' === typeof callback) {
          return callback(result);
        } else {
          return result;
        }
      });
    });
  };
  data.db.find = function(collection, queryArgs, callback) {
    return this.db.collection(collection, function(err, collection) {
      if (err) {
        console.error(err.stack);
      }
      return collection.find(queryArgs.query, queryArgs.field, queryArgs.skip, queryArgs.limit, function(err, cursor) {
        if (err) {
          console.error(err.stack);
        }
        if (queryArgs.sort) {
          cursor = cursor.sort(queryArgs.sort);
        }
        if ('function' === typeof callback) {
          return data.onFindCursor(err, cursor, callback);
        } else {
          return data.onFindCursor(err, cursor);
        }
      });
    });
  };
  data.db.findOne = function(collection, query, callback) {
    query.limit = 1;
    return this.find(collection, query, callback);
  };
  data.onFindCursor = function(err, cursor, callback) {
    if (err) {
      console.error(err.stack);
    }
    if ('function' === typeof callback) {
      return cursor.toArray(function(err, items) {
        if (err) {
          console.error(err.stack);
        }
        return callback(items);
      });
    } else {
      return cursor.toArray();
    }
  };
}).call(this);
