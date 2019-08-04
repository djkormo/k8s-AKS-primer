// Copyright 2017, Google, Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
var http = require('http');
var fs = require('fs');
var server = http.createServer(function (request, response) {
  fs.readFile('./config/config.json', function (err, config) {
    if (err) return console.log(err);
    const language = JSON.parse(config).LANGUAGE;
    fs.readFile('./secret/secret.json', function (err, secret) {
      if (err) return console.log(err);
      const API_KEY = JSON.parse(secret).API_KEY;
      response.write(`Language: ${language}\n`);
      response.write(`API Key: ${API_KEY}\n`);
      response.end(`\n`);
    });
  });
});
server.listen(3000);