#!/usr/bin/env node

const http = require('http');
let port = process.argv[2] || 8000;

const requestHandler = (request, response) => {
	let body = [];
	request.on('data', (chunk) => {
		body.push(chunk);
	}).on('end', () => {
		body = Buffer.concat(body).toString();
		// at this point, `body` has the entire request body stored in it as a string
		console.log(body);

		response.writeHead(201, {
			'Content-Type': 'application/json',
			'X-Powered-By': 'bacon'
		});
		response.end(JSON.stringify({
			'OK': 201
		}));
	});
}

const server = http.createServer(requestHandler)

server.listen(port, (err) => {
	if (err) {
		return console.log('something bad happened', err)
	}

	console.log(`server is listening on ${port}`)
});
