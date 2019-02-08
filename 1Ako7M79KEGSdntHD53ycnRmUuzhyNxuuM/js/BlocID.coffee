class BlocID extends ZeroFrame
	init: ->
		@users = {}
		@auth_address = null
		@site_info = null

		$(".button-get").on "click", -> # Get Certificate button
			$(".panel-intro .text-gotauth, .panel-intro .text-noauth").css("transition", "none") # Chrome flicker workaround
			$(".ui").toggleClass("flipped")
			return false

		$(".togglesend").on "click", -> # Toggle between bitmessage / direct send
			if $(".send-direct").hasClass("active") # Show bitmessage
				$(".send-bitmessage").css("display", "inherit").addClassLater("active", 10)
				$(".send-direct").removeClass("active").cssLater("visibility", "hidden", 300)
			else # Hide bitmessage
				$(".send-bitmessage").removeClass("active", 10).hideLater(300)
				$(".send-direct").cssLater("visibility", "visible", 1).addClassLater("active", 10)

		$(".username").on "input", => # Check if username valid on keypress
			LimitRate 50, => # Check if user name taken
				val = $(".username").val().toLowerCase()
				val = val.replace /[^a-z0-9]/g, ""
				if val != $(".username").val() then $(".username").val(val)
				$(".username-status").removeClass("error ok")
				$(".bitmessage-message").text("Enter username you want to register")
				$(".bitmessage-address").text("n/a")

				if @users[val]
					$(".username-status").attr "title", "User name #{val} is already taken!"
					$(".username-status").addClass("error")
					$(".username-status .title").text("taken")
				else if val != ""
					$(".username-status").attr "title", "User name #{val} is available"
					$(".username-status").addClass("ok")
					$(".username-status .title").text("ok")
					$(".bitmessage-message").text("add:#{@auth_address}:#{val}")
					$(".bitmessage-address").text("BM-2cUhFY6Ay2LSZZTJ1por17uRWa2oXGQKuK")
				else
					$(".username-status .dot").attr "title", "Enter a user name you want to register"
					$(".username-status .title").text("")

		$(".button-send").on "click", => # Send certificate request button
			if $(".username").val() == ""
				$(".username-status .title").text("missing")
				$(".username-status").addClass("error")
			if $(".username-status").hasClass("error")
				$(".username").focus()
			else
				@sendRequest()
			return false

		$(".search").on "click", =>  # Search in users
			$(".ui-register").addClass("hidden")
			$(".ui-search").removeClass("hidden")
			$(".ui-search .search-username").focus()

		$(".search-username").on "input", =>
			LimitRate 50, => # Check if user name taken
				val = $(".search-username").val().toLowerCase()
				val = val.replace /[^a-z0-9]/g, ""
				if val != $(".search-username").val() then $(".search-username").val(val)
				$(".username-status").removeClass("error ok")
				if @users[val]
					$(".username-status").addClass("ok")
					$(".username-status .title").text("found")
					if Page.server_info.rev > 1880
						$(".button-mute").css("opacity", 1)
				else if val != ""
					$(".username-status").addClass("error")
					$(".username-status .title").text("not found")
					$(".button-mute").css("opacity", 0)
				else
					$(".username-status .title").text("")
					$(".button-mute").css("opacity", 0)

		$(".search-back").on "click", =>
			$(".ui-register").removeClass("hidden")
			$(".ui-search").addClass("hidden")

		$(".button-mute").on "click", =>
			val = $(".search-username").val()
			$(".button-mute").addClass("loading")
			@searchAuthAddress val, (user_name, cert) =>
				$(".button-mute").removeClass("loading")
				[auth_type, auth_address, cert_sign] = cert.split(",")
				@log "Muting", auth_address
				Page.cmd "muteAdd", [auth_address, val+"@bloc.bit", ""], =>
					Page.cmd "wrapperNotification", ["done", "User #{val}@bloc.bit muted!"]

	# Route incoming requests
	route: (cmd, message) ->
		if cmd == "setSiteInfo" # Site updated
			@log message.params.event, message
			@site_info = message.params
			if message.params.event?[0] == "file_done" and message.params.event?[1].indexOf("data/users") == 0
				@setRequestPercent(100)
				@endRequest()
				@reloadUsers()
		else
			@log "Unknown command", message


	setRequestPercent: (percent) ->
		if $(".button-send").hasClass "loading"
			$(".button-send").css("box-shadow", "inset #{percent*1.2}px 0px rgba(0,0,0,0.1)")


	sendRequest: ->
		$(".button-send").addClass("loading")
		$(".username").attr("readonly", "true")
		@setRequestPercent(10)

		$.post "https://192.168.1.106/request.php", {"auth_address": @auth_address, "user_name": $(".username").val(), "width": $(".ui h1").width() }, (res) =>
			@setRequestPercent(20)
			if res[0] == "{" # Valid response, solve task
				res = JSON.parse(res)
				@solveTask(res)
			else # Invalid response
				@cmd "wrapperNotification", ["error", res]
				@endRequest()
		.fail (err) =>
			@cmd "wrapperNotification", ["error", "Error while during request: #{err.statusText}<br>#{err.responseText}"]
			@endRequest()


	solveTask: (task) ->
		try
			solution = eval(task.work_task)
		catch err
			@cmd "wrapperNotification", ["error", "Error while solving: #{err.message}"]
			@endRequest()
			return false
		@setRequestPercent(30)
		# Sending back solution...

		$.post "https://192.168.1.106/solution.php", {"auth_address": @auth_address, "user_name": $(".username").val(), "work_id": task.work_id, "work_solution": solution }, (res) =>
			if res == "OK"
				@setRequestPercent(80) # Solution ok, site change published, waiting for update
			else
				@cmd "wrapperNotification", ["error", "Solve error: #{res}"]
				@endRequest()
		.fail (err) =>
			@cmd "wrapperNotification", ["error", "Error while during sending solution: #{err.statusText}<br>#{err.responseText}"]
			@endRequest()


	endRequest: ->
		$(".button-send").removeClass("loading")
		$(".username").removeAttr("readonly")
		$(".button-send").css("box-shadow", "")


	onOpenWebsocket: ->
		@cmd "siteInfo", "", (res) =>
			@auth_address = res["auth_address"]
			@site_info = res
			@reloadUsers()

		@cmd "serverInfo", {}, (server_info) =>
			@server_info = server_info
			if server_info.rev < 160
				$(".panel-intro .button-get").css("display", "none")
				$(".panel-intro .please-update").css("display", "inline-block")


	setStatusTitle: (status_title) ->
		if @status_timer then clearInterval(@status_timer)
		elem = $(".status-title")
		if status_title == elem.text()
			return
		@log "Status: #{status_title}"
		if status_title == ""
			elem.css("display", "none")
			return
		elem.css("transform", "translateY(20px)").css("opacity", 0)
		@status_timer = setTimeout ( =>
			elem.text(status_title)
			elem.css("transition", "none")
			elem.css("transform", "translateY(-20px)").css("opacity", 0)
			@status_timer = setTimeout ( ->
				elem.css("transition", "")
				elem.css("transform", "translateY(0px)").css("opacity", 1)
			), 10
		), 600

	loadCert: (cert_filename, user_name, cb) ->
		Page.cmd "fileGet", cert_filename, (res) =>
			res = JSON.parse(res)
			cb(user_name, res["certs"][user_name])

	searchAuthAddress: (search, cb) ->
		@setStatusTitle "Searching for : #{search}"
		found = 0
		found_cert = false
		pending_request = 0
		for user_name, cert of @users
			if cert.startsWith("@")
				[cert_file_id, auth_address_pre] = cert.replace("@", "").split(",")
				if search.startsWith(auth_address_pre) or user_name == search
					found += 1
					cert_filename = "certs_#{cert_file_id}.json"
					@setStatusTitle("Recovering certificate from #{cert_filename}...")
					@log "Possible optional file cert: #{cert} #{user_name}"
					pending_request += 1
					@loadCert "data/#{cert_filename}", user_name, (user_name, cert) =>
						pending_request -= 1
						[auth_type, auth_address, cert_sign] = cert.split(",")
						if auth_address == search or user_name == search
							found_cert = true
							@log "Found valid cert: #{cert}"
							cb(user_name, cert)
						else
							@log "Invalid cert: #{cert}"
						if pending_request == 0
							@log "Found cert: #{found_cert}"
							if not found_cert
								cb(false, false)
			else
				[auth_type, auth_address, cert_sign] = cert.split(",")
				if auth_address == search or user_name == search
					@log "Cert found directly: #{cert}"
					found += 1
					cb(user_name, cert)
		if found == 0
			cb(false, false)


	reloadUsers: ->
		@setStatusTitle("Loading users data (1/2)...")
		@cmd "fileGet", "data/users_archive.json", (res) =>
			@users = JSON.parse(res)["users"]
			@setStatusTitle("Loading users data (2/2)...")
			@cmd "fileGet", "data/users.json", (res) =>
				for user, data of JSON.parse(res)["users"]
					@users[user] = data
				gotauth = false
				@searchAuthAddress @auth_address, (user_name, cert) =>
					@setStatusTitle("")
					if cert
						[auth_type, auth_address, cert_sign] = cert.split(",")
						@setCert(auth_type, user_name, cert_sign)
						gotauth = true
					else
						$(".panel-intro").addClass("noauth")



	setCert: (auth_type, user_name, cert_sign) ->
		$(".panel-intro").removeClass("noauth")
		$(".panel-intro").addClass("gotauth")
		$(".current-auth b").text("#{auth_type}/#{user_name}@bloc.bit")
		@cmd "certAdd", ["bloc.bit", auth_type, user_name, cert_sign], (res) =>
			$(".ui").removeClass("flipped")
			if res.error
				@cmd "wrapperNotification", ["error", "#{res.error}"]



window.Page = new BlocID()
