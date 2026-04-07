class LocalBase
	def initialize(hostPaths, guestPaths, vagrantConfig, settings)
		@hostPaths = hostPaths
		@guestPaths = guestPaths
		@vagrantConfig = vagrantConfig
		@settings = settings
	end

	def configure
		#
		# Add a new user on the guest matching the name, uid and gid of the user on the host.
		# the guest.
		#
		@vagrantConfig.vm.provision "shell" do |s|
			s.name = "Adding user on guest."
			s.privileged = "true"
			s.path =  @hostPaths.scripts + "/add-user.sh"
			s.args = @settings["host_os"], @settings["username"], Process.uid, Process.gid, @guestPaths.home
		end

		@vagrantConfig.vm.provision "shell" do |s|
			s.name = "Creating config directory."
			s.inline = "mkdir -p " + @guestPaths.home + "/.config"
		end

		copyFile("~/.aws", @guestPaths.home + "/.aws")

		#
		# Copy mysql user config.
		#
		if @settings.include? "mysql_server" then
			createMySQLServer(@settings["mysql_server"])
		else
			abort "Need to specify a mysql_client"
		end

		# Fix file permisions of all files copied by above.
		if @settings["host_os"] == "linux" then
			group = "users"
		else
			group = Process.gid.to_s
		end

		@vagrantConfig.vm.provision "shell" do |s|
			s.name = "Fixing permisions."
			s.privileged = true
			s.inline = "chown -R " + @settings['username'] + ":" + group + " " + @guestPaths.home
		end
	end

	def copyFile(hostSrc, guestDst)

		hostPath = File.expand_path(hostSrc)
		fileName = File.basename(hostSrc)

		if File.exist? hostPath then

			@vagrantConfig.vm.provision "file" do |f|
				#f.name = "Copying file cache to guest."
				f.source = hostPath
				f.destination = '/tmp/' + fileName
			end

			@vagrantConfig.vm.provision "shell" do |s|
				s.name = "Loading " + hostPath + "."
				s.inline = "cp -rf $1 $2"
				s.args = "/tmp/" + fileName, guestDst
			end

			@vagrantConfig.vm.provision "shell" do |s|
				s.name = "Removing " + fileName + " temporary file."
				s.inline = "rm -rf $1"
				s.args = '/tmp/' + fileName
			end

		else
			#abort "Can not find " + hostPath + "!"
		end
	end

	def copyDir(hostSrc, guestDst)

		hostPath = File.expand_path(hostSrc)
		fileName = File.basename(hostSrc)

		if File.exist? hostPath then

			@vagrantConfig.vm.provision "file" do |f|
				#f.name = "Copying file cache to guest."
				f.source = hostPath
				f.destination = '/tmp/' + fileName
			end

			@vagrantConfig.vm.provision "shell" do |s|
				s.name = "Loading " + hostPath + "."
				s.inline = "cp -rf $1 $2"
				s.args = "/tmp/" + fileName + "/.", guestDst
			end

			@vagrantConfig.vm.provision "shell" do |s|
				s.name = "Removing " + fileName + " temporary file."
				s.inline = "rm -rf $1"
				s.args = '/tmp/' + fileName
			end

		else
			#abort "Can not find " + hostPath + "!"
		end
	end

	def createMySQLServer(settings)

		#
		# Install mysql and add users.
		#
		@vagrantConfig.vm.provision "shell" do |s|
			s.name = "Installing MySQL Database."
			s.privileged = "true"
			s.path = @hostPaths.scripts + "/install-mysql.sh"
			s.args = @guestPaths.deployFiles, settings["username"], settings["password"], settings["database"]["name"]
		end
	end
end
