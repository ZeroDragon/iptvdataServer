request = require 'request'
fs      = require 'fs'
config  = require './config.json'
express = require 'express'

app = express()
config.cacheTime*=60

getGuia = (cb)->
	console.log 'Vamos por la Guia'
	await request.get config.guia, defer(err,data)
	throw err if err
	fs.writeFileSync config.output+'guia.xml', data.body
	cb true

getLogos = (cb)->
	console.log 'Vamos por los logos'
	await request.get config.logos, defer(err,data)
	throw err if err
	data.body = data.body.replace(/href="/g,'href="'+config.logos)
	fs.writeFileSync config.output+'logos.html', data.body
	cb true

app.get '/guia.xml', (req,res)->
	guiaTime = ~~(new Date((fs.statSync config.output+'guia.xml').mtime).getTime()/1000)
	now = ~~(new Date().getTime()/1000)
	if guiaTime+config.cacheTime < now
		getGuia -> res.sendFile __dirname+'/'+config.output+'guia.xml'
	else
		console.log 'Guia aun válida'
		res.sendFile __dirname+'/'+config.output+'guia.xml'

app.get '/logos', (req,res)->
	logosTime = ~~(new Date((fs.statSync config.output+'logos.html').mtime).getTime()/1000)
	now = ~~(new Date().getTime()/1000)
	if logosTime+config.cacheTime < now
		getLogos -> res.sendFile __dirname+'/'+config.output+'logos.html'
	else
		console.log 'Logos aun válidos'
		res.sendFile __dirname+'/'+config.output+'logos.html'

app.listen config.port, ()-> console.log 'Server UP'