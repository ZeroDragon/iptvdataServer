request = require 'request'
fs      = require 'fs'
config  = require './config.json'
express = require 'express'

app = express()
config.cacheTime*=60

getFile = (file,cb)->
	fetchFile = (cb)->
		console.log 'Vamos por '+file
		await request.get config[file], defer(err,data)
		fs.writeFileSync config.output+file, data.body
		cb true

	unless fs.existsSync config.output+file
		fetchFile cb
	else
		fileTime = ~~(new Date((fs.statSync config.output+file).mtime).getTime()/1000)
		now = ~~(new Date().getTime()/1000)
		if fileTime+config.cacheTime < now
			fetchFile cb
		else
			console.log file+' OK'
			cb true

app.get '/guia.xml', (req,res)->
	await getFile 'guia.xml', defer status
	res.sendFile __dirname+'/'+config.output+'guia.xml'

app.get '/logos', (req,res)->
	await getFile 'logos.html', defer status
	res.sendFile __dirname+'/'+config.output+'logos.html'

app.listen config.port, ()-> console.log 'Server UP'