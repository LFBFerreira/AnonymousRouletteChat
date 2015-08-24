Db = require 'db'
Event = require 'event'
Photo = require 'photo'
Plugin = require 'plugin'
Timer = require 'timer'
{tr} = require 'i18n'

exports.client_chat = (text, delay) !->
	if delay
		Timer.set 15000, 'client_chat', text
	else
		post {text}, text

exports.onPhoto = (info, delay) !->
	if delay
		Timer.set 15000, 'onPhoto', info
	else
		post {photo: info.key}, tr("(photo)")

post = (msg, eventText) !->
	msg.time = Math.floor(Date.now()*.001)

	randNum = Math.random()
	msg.prob = randNum.toFixed(2)

	if randNum < .2
		msg.userId = Plugin.userId()
		msg.showId = true
	else
		msg.showId = false

	id = Db.shared.modify 'maxId', (v) -> (v||0)+1
	Db.shared.set Math.floor(id/100), id%100, msg

	Event.create
		text: "Anonymous: #{eventText}"
		sender: Plugin.userId()

exports.client_removePhoto = (num) !->
	Plugin.assertAdmin()
	msg = Db.shared.ref(Math.floor(num/100), num%100)
	if photo=msg.get('photo')
		Photo.remove msg.get('photo')
		msg.set 'photo', ''
