mongo tracking ./mongo.reset.js 
mongoimport -d tracking -c records ./data.records.json
mongoimport -d tracking -c apps ./data.apps.json
mongo tracking
