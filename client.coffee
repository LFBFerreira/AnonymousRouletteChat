Db = require 'db'
Dom = require 'dom'
Chat = require 'chat'
Event = require 'event'
Form = require 'form'
Obs = require 'obs'
Page = require 'page'
Photo = require 'photo'
Plugin = require 'plugin'
Server = require 'server'
Time = require 'time'
Ui = require 'ui'
{tr} = require 'i18n'

exports.render = !->
	log 'render'
	
	Dom.style
		fontSize: '90%'

	Chat.renderMessages
		newCount: Obs.peek -> Event.unread() || 0
		content: (msg, num) !->
			return if !msg.isHash()
			# normal message
			Dom.div !->
				Dom.cls 'chat-msg'
				
				Dom.div !->
					Dom.cls 'chat-content'
					Dom.style margin: '2px'
					photoKey = msg.get('photo')
					if photoKey
						Dom.img !->
							Dom.prop 'src', Photo.url(photoKey, 200)
							Dom.onTap !->
								Page.nav !->
									renderPhoto msg, num
										
					else if photoKey is ''
						Dom.div !->
							Dom.cls 'chat-nophoto'
							Dom.text tr("Photo")
							Dom.br()
							Dom.text tr("removed")

					text = msg.get('text')
					Dom.userText text if text

					Dom.div !->
						Dom.cls 'chat-info'
						if time = msg.get('time')
							Time.deltaText time, 'short'
						else
							Dom.text tr("sending")
							Ui.dots()

	Page.setFooter !->
		opts = {}
		Dom.div !->
			Dom.style
				fontSize: '85%'
				margin: '0 0 -4px 6px'
				Box: 'middle'

			Dom.div !->
				Dom.style Flex: 1
				Dom.text tr("Messages or photos will be anonymous.")
				#Dom.div !->
				#	Dom.style fontSize: '85%'
				#	Dom.text tr("(even for group admins)")

			Dom.div !->
				Dom.style
					Box: 'middle'
					padding: '3px 6px'
				Dom.input !->
					Dom.cls 'form-check'
					Dom.prop 'type', 'checkbox'
					Dom.style
						margin: '0 3px 0 0'
						zoom: '80%'
						pointerEvents: 'none' # tap is handled by parent
				inputE = Dom.last()

				Dom.div !->
					Dom.text tr("15s delay")

				Dom.onTap !->
					checked = !inputE.prop('checked')
					inputE.prop 'checked', checked
					opts.rpcArg = checked # bit of a hack to set it on the ref, but works well
			
		Chat.renderInput opts

renderPhoto = (msg, num) !->

	photoKey = msg.get('photo')

	Page.setTitle tr("Photo")
	opts = []
	if Photo.download
		opts.push
			label: tr("Download")
			icon: 'boxdown'
			action: !-> Photo.download photoKey
	if Plugin.userIsAdmin()
		opts.push
			label: tr("Remove")
			icon: 'trash'
			action: !->
				require('modal').confirm null, tr("Remove photo?"), !->
					Server.sync 'removePhoto', num, !->
						msg.set('photo', '')
					Page.back()
	Page.setActions opts

	Dom.style
		padding: 0
		backgroundColor: '#444'
		
	(require 'photoview').render
		key: photoKey

