urlParser = require('url');
express = require('express');
util = require('util');

CONSTANTS = require('./constants');
APP_CONFIG = require('./config');
PROPERTIES = [CONSTANTS.TAGS.PLATFORM, CONSTANTS.TAGS.APP_NAME, CONSTANTS.TAGS.TAG]
db = require('./mongo');
tracker = tracker || {};
tracker.mPublic = exports;

tracker.mPrivate = {}
tracker.mPrivate = exports;  #for test only#

tracker.mPublic.handleRequest = (req, callback) ->
	record = tracker.mPrivate.getRecordFromRequest(req);

	isValid = tracker.mPrivate.checkRecord(record);
	if (!isValid) 
	  console.log 'Invalid request, it should contain platform app_name and tag'		
	  console.log record
	else 
		record = tracker.wrapRecord(record, req);
		tracker.saveRecord(record);
		if 'function' is typeof callback
			callback(record)
		else
		  record

#tracker.mPublic.find = (collection, query, callback) ->
#	db.find(collection, query, callback);	

#tracker.mPublic.distinct = (collection, field, query, callback) ->
#	db.distinct(collection, field, query, callback);	
tracker.mPrivate.find = db.find
tracker.mPrivate.distinct = db.distinct
tracker.mPrivate.save = db.save
	
tracker.mPublic.getAllAppIDs = (callback) ->
  tracker.distinct('apps','app_id',{},callback)

tracker.mPublic.findByTagDateRange = (app_id, tag, startDate, endDate, callback)-> 
	query = 
		query: 
			app_id: app_id,
			tag: tag,
			time: 
				$gte: startDate,
				$lt: endDate,
	tracker.mPrivate.find('records', query, callback);

	# todo check if the _id is already exist, if it is, return directly and no need to save it into db;	
tracker.mPrivate.saveRecord = (record, callback)-> 
  tracker.mPrivate.getAppInfo record, (app)->
	  tracker.mPrivate.saveApp app, (app) -> 
		  #record._id = 1; // mark the id to 1, as id for each record is not important
		  record.app_id = app._id;
		  delete record.platform;
		  delete record.app_name;
		  tracker.mPrivate.save('records', record, util.log('saved record'));
		  
tracker.mPrivate.saveApp = (app, callback) -> 
	tracker.mPrivate.save 'apps', app, (app)->
  	if 'function' is typeof callback then callback app else return app


tracker.mPrivate.getAppInfo = (record, callback)->
  app =
	  platform: record.platform,
	  app_name: record.app_name,
  app._id = app.platform + '_' + app.app_name;
  if 'function' is typeof callback then callback app else return app

tracker.mPrivate.checkRecord = (record) ->
	result = true;
	for property in PROPERTIES
		if (not record[property]?) 
			console.error(property + ' is undefined, record ignored.');
			result = false;
			break
	result;

tracker.mPrivate.wrapRecord = (record, req, callback) ->
	record.UA = req.headers['user-agent'];
	record.IP = tracker.getClientAddress(req);
	delete record.noCache;

	if (record.userid? && not record.uid?) 
		record.uid = record.userid;
		delete record.userid;
	
#	//todo convert count and sum to number.
#	if (record.count) {
#		record.count = Number(record.count);
#		if (isNaN(record.count)) {
#			console.warn('record.count is NaN');
#			delete record.count;
#		}
#	}

#	if (record.sum) {
#		record.sum = Number(record.sum);
#		if (isNaN(record.sum)) {
#			console.warn('record.sum is NaN');
#			delete record.sum;
#		}
#	}

	record.time = new Date();
	if 'function' is typeof callback then callback(record) else return record
#	return record;

tracker.mPrivate.getClientAddress = (req) ->
	req.headers['x-forwarded-for'] or req.connection.remoteAddress;


tracker.mPrivate.getRecordFromRequest = (req) ->
	if (req.method is 'GET')
		content = urlParser.parse(req.url, true);
		record = content.query;	
	else 
		record = req.body;
		
tracker.mPrivate.closeDB =()->
  if not db.isClosed()
    db.close()

tracker.mPrivate.openDB = (callback)->
  if db.isClosed()
  #  console.log 'Open database in track'
    db.open
	    dbName: APP_CONFIG.DATABASE.DB_NAME, callback

tracker.mPrivate.openDB()
