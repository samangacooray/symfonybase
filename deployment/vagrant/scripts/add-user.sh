#!/usr/bin/env bash
HOST_OS=$1
HOST_USERNAME=$2
HOST_UID=$3
HOST_GID=$4
HOST_HOME_DIR=$5

if [ "${HOST_OS}" == "osx" ]; then
	echo "Adding user ${HOST_USERNAME} ${HOST_UID}:${HOST_GID}"

	# Try and make a new group.
	if ! groupadd --gid ${HOST_GID} ${HOST_USERNAME}; then
		# If the group already exists then repurpose it.
		echo "group exists, repurposing existing group."
		GROUP_NAME=`grep :${HOST_GID}: /etc/group | cut -d':' -f1`
		groupmod --gid ${HOST_GID} --new-name ${HOST_USERNAME} ${GROUP_NAME} 
	fi

	useradd -m -s /bin/bash -N ${HOST_USERNAME} -u ${HOST_UID} -g ${HOST_GID} --groups sudo,vagrant

	# Add the user to the vagrant group.
	usermod -a -G ${HOST_GID} vagrant

	cp -pr /home/vagrant/.ssh /home/${HOST_USERNAME}
	chown -R ${HOST_UID}:${HOST_GID} /home/${HOST_USERNAME}/.ssh

else
	# Try and make a new group.
	if ! groupadd --gid ${HOST_GID} ${HOST_USERNAME}; then
		# If the group already exists!
		echo "group ${HOST_GID} exists on the host, you need a user on the host that doesn't conflict with a user on the guest."
		echo "There is a vagrant user on the guest, with uid:1000 gid:1000, which is probably uid on the host!"
		exit 1
	fi

	useradd -m -s /bin/bash -N ${HOST_USERNAME} -u ${HOST_UID} -g ${HOST_GID} --groups sudo,vagrant

	# Add the user to the vagrant group.
	usermod -a -G ${HOST_GID} vagrant

	cp -pr /home/vagrant/.ssh /home/${HOST_USERNAME}
	chown -R ${HOST_USERNAME}:${HOST_GID} /home/${HOST_USERNAME}/.ssh
fi


	
