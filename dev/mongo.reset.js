db.apps.remove();
db.records.remove();
db.apps.dropIndexes();
db.records.dropIndexes();
db.apps.ensureIndex({app_name:1,platform:1});
db.records.ensureIndex({app_id:1,tag:1,time:1});
