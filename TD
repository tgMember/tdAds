#!/bin/bash

function update() {
  sudo git pull
  sudo git fetch --all
  sudo git reset --hard origin/master
  sudo git pull origin master
  sudo chmod 7777 TD
}

function conf() {
dirbot=~/.telegram-bot/td-$1/td.lua
if [[ ! -f $dirbot ]]; then
echo "Ads_id = '$1'

serpent = require('serpent')

require('TD')

function tdbot_update_callback(data)
	Doing(data, Ads_id)
end" >> $dirbot
fi
}

function cfg() {
cfg=~/.telegram-bot/td-$1/config
if [[ ! -f $cfg ]]; then
echo 'default_profile = "td-'$1'";
td-'$1' = {
	config_directory = "td-'$1'";
	test = false;
	use_file_db = true;
	use_file_gc = true;
	file_readable_names = true;
	use_secret_chats = false;
	use_chat_info_db = true;
	use_message_db = true;
  	logname = "log.txt";
	verbosity = 0;
	lua_script = "td.lua";
};' >> $cfg
fi
}

function setsudo() {
echo -e "\033[38;5;27m\n"

 read -p 'put your user-Id :'  -e input
		redis-cli sadd tg:$1:sudo $input
}

function loginbot() {
logdr=~/.telegram-bot/td-$1/log.txt
if [ ! -f $logdr ]; then
echo -e "\033[38;5;208m\n\033[6;48m\n"

	read -p 'Phone number :'  -e input
  ./telegram-bot -p td-$1 -L log.txt --login --phone=$input
	
fi
}

function loginapi() {
logdr=~/.telegram-bot/td-$1/log.txt
if [ ! -f $logdr ]; then
echo -e "\033[38;5;208m\n\033[6;48m\n"

	read -p 'TOKEN :'  -e input
  ./telegram-bot -p td-$1 -L log.txt --login --bot=$input
	
fi
}

function botmod() {
 echo -e "\033[38;5;208mSelect your Robot Mod Configuration\033[1;208m"
    read -p "API [A/a] - CLI [C/c]"
  if [ "$REPLY" == "A" ] || [ "$REPLY" == "a" ]; then
	loginapi $1
    elif [ "$REPLY" == "C" ] || [ "$REPLY" == "c" ]; then
    	loginbot $1
  fi
}

runbt() {
drbt=~/.telegram-bot/td-$1
 	if [ ! -d $drbt ]; then
 		mkdir ~/.telegram-bot/td-$1
		setsudo $1
 		conf $1
		cfg $1
		botmod $1
		echo -e "\n\033[38;0;0m\n"
	fi
}

autolaunch() {
COUNTER=0
  while [ $COUNTER -lt 9 ]; do
    sleep 1
	let COUNTER=COUNTER+1
       	sudo tmux kill-session -t td-$1
		sudo tmux new-session -d -s td-$1 "./telegram-bot -d -c ~/.telegram-bot/td-$1/config"
        sudo tmux detach -s td-$1
sleep 2	
	printf "\r\033[1;31m tdAds bot $COUNTER runing ..."
  done
printf "\n\e[38;0;0m"
}

if [ ! -d ~/.telegram-bot ]; then
	mkdir ~/.telegram-bot
elif [ "$1" = "upgrade" ]; then
  	sudo rm -rf telegram-bot
	update
	wget https://valtman.name/files/telegram-bot-$(date +%y%m%d)-nightly-linux
	mv telegram-bot-$(date +%y%m%d)-nightly-linux telegram-bot; chmod +x telegram-bot
elif [[ "$1" =~ ^[0-9]+$ ]] ; then
runbt $1
  while true; do
	sudo tmux kill-session -t td-$1
		sudo tmux new-session -s td-$1 "./telegram-bot -d -c ~/.telegram-bot/td-$1/config"
        sudo tmux detach -s td-$1
  done
else
 autolaunch
fi
