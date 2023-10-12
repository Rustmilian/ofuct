#!/bin/bash

# Colors
# BL='\e[01;90m' # Black
RE='\e[06;91m' # Red-Error
# R='\e[01;91m'  # Red
G='\e[01;92m'  # Green-Success
Y='\e[01;93m'  # Yellow
B='\e[01;94m'  # Blue
P='\e[01;95m'  # Purple
C='\e[01;96m'  # Cyan
LG='\e[01;37m' # LightGray
N='\e[0m'      # Null



# Divider
divider="-------------------------------------------------"

# OFox Compiler Header
strings=(
"  @@@@@@  @@@@@@@@  @@@@@@  @@@  @@@     @@@@@@@  @@@@@@  @@@@@@@@@@   @@@@@@@  @@@ @@@     @@@@@@@@ @@@@@@@   "
" @@@@@@@@ @@@@@@@@ @@@@@@@@ @@@  @@@    @@@@@@@@ @@@@@@@@ @@@@@@@@@@@  @@@@@@@@ @@@ @@@     @@@@@@@@ @@@@@@@@  "
" @@!  @@@ @@!      @@!  @@@ @@!  !@@    !@@      @@!  @@@ @@! @@!  @@! @@!  @@@ @@! @@!     @@!      @@!  @@@  "
" !@!  @!@ !@!      !@!  @!@ !@!  @!!    !@!      !@!  @!@ !@! !@!  !@! !@!  @!@ !@! !@!     !@!      !@!  @!@  "
" @!@  !@! @!!!:!   @!@  !@!  !@@!@!     !@!      @!@  !@! @!! !!@  @!! !!@@!@!  !!@ @!!     @!!!:!   @!@!!@!   "
" !@!  !!! !!!!!:   !@!  !!!   @!!!      !!!      !@!  !!! !@!   !  !@! !!@!!!   !!! !!!     !!!!!:   !!@!@!    "
" !!:  !!! !!:      !!:  !!!  !: :!!     :!!      !!:  !!! !!:      !!: !!:      !!: !!:     !!:      !!: :!!   "
" :!:  !:! :!:      :!:  !:! :!:  !:!    :!:      :!:  !:! :!:     :!:  :!:      :!: :!:     :!:      :!:  !:!  "
" ::::::::  ::      ::::: ::  ::  :::     ::: ::: ::::: :: :::     ::    ::       :: ::!::!  :: ::::  ::   ::   "
"  : :  :   :        : :  :   :   ::      :: :: :  : :  :   :      :     :        :   : :: :  : :: ::  :   :    "
)

for string in "${strings[@]}"
do
  printf "${Y}%s${N}\n" "$string"
  sleep 0.1
done

# Welcome
echo -e "${B} Hello, Thank you for using this script ${N}"
echo -e "${Y} With this script you can easily build OrangeFox Recovery for any device! ${N}"
sleep 5
clear

# Setup
echo -e "${C} Setup the environment ${N}"
sudo apt install git python aria2 nano -y || sudo pacman -S git aria2 python nano --needed

cd ~/ || echo "cd $HOME failed" exit
if ! git clone https://gitlab.com/OrangeFox/misc/scripts; then
  echo -e "${RE} Failed to clone OrangeFox scripts ${N}"
  exit 1
fi
cd scripts || echo "cd scripts failed" exit
sudo bash setup/android_build_env.sh
sudo bash setup/install_android_sdk.sh
clear


# Sync
echo -e "${Y} Options
 1 : For Normal device (slow)
 2 : For Dynamic partition device (very very slow)
 -------------------------------------------------------------------------------------------------------------- ${N}"

read -r Ans1
clear
if [[ "${Ans1}" = 1 ]]; then
	fox=OrangeFox
	echo -e "${C} synching the Latest Orange Fox Sources ${N}"; sleep 0.1;
	cd ~/scripts || return
	mkdir -p Orangefox
	cd Orangefox || return
	repo init --depth=1 -u https://gitlab.com/OrangeFox/Manifest.git -b fox_9.0 > /dev/null 2>&1
	repo sync -j8 --force-sync > /dev/null 2>&1 &
	sleep 2
	clear
	cd ~/scripts/Orangefox || return
elif [[ "${Ans1}" = 2 ]]; then
	fox=OrangeFox_10
	echo -e "${C} synching the Latest Orange Fox Sources ${N}"; sleep 0.1;
	mkdir -p ~/OrangeFox_10
	cd ~/OrangeFox_10 || return
	rsync rsync://sources.orangefox.download/sources/fox_10.0 . --progress -a > /dev/null 2>&1 &
	sleep 2
fi
clear

# Questions
echo -e "${P} Now tell me your device codename ${N}"; read -r code
echo "$divider"
echo -e "${P} Now tell me your device vendor ${N}"; read -r vendor
echo "$divider"
echo -e "${P} Now Give me your device trees github link ${N}"; read -r trees
echo "$divider"
echo -e "${P} Now tell me the your name (Username) ${N}"; read -r main
echo "$divider"
echo -e "${P} Now tell me the version ${N}"; read -r version
clear

# Clone
echo -e "${C} Cloning to scripts/${fox}/device/$vendor/$code ${N}"; sleep 0.1;
git --depth 1 clone "${trees}" device/"${vendor}"/"${code}"
sleep 2
clear

# Edit Bconfig.mk
echo -e "${LG} If you have to edit the cloned tree (e.g. BoardConfig.mk) do it now. ${N}"; sleep 0.1;
echo -e "${P} "Press Enter to Continue" ${N}"; sleep 0.1;
read -r
clear

# Environment
echo -e "${C} Now lets start building the environment ${N}"
source build/envsetup.sh;
sleep 5
clear

# Configs
echo -e "${Y}  Options
 1 : You already have a config file created by this script
 2 : You don't have a config file and now we will create it for you and will use it later when rebuilding Ofox
 --------------------------------------------------------------------------------------------------------------  ${N}"
read -r Ans2

if [[ "${Ans2}" = 1 ]]; then
echo "continuing"
elif [[ "${Ans2}" = 2 ]]; then
echo -e "${Y} Lets create a config file using our good friend nano for your device var settings.
(https://gitlab.com/OrangeFox/vendor/recovery/-/blob/master/orangefox_build_vars.txt) ${N}"; sleep 2;
nano ~/ofuct/hwconf/"${code}"_hwconf
fi
clear

# Import Configs
echo -e "${C} Importing Configs ${N}"

if ! source ~/ofuct/hwconf/"${code}"_hwconf; then
  echo -e "${RE} Import failed :( ${N}"
  exit
fi
sleep 1


# Maintainer
export OF_MAINTAINER="${main}"
# Universal Build Configs
export ALLOW_MISSING_DEPENDENCIES=true
export TW_DEFAULT_LANGUAGE="en"
export USE_CCACHE=1
export FOX_R11=1
export FOX_ADVANCED_SECURITY=1
export FOX_RESET_SETTINGS=1
export FOX_VERSION="${version}"

echo -e "${G} Press Enter to Launch ${N} 🚀"
echo "$divider"
read -r

# Launch
if ! lunch omni_"${code}"-eng; then
  echo -e "${RE} Launch failed :( ${N}"
  exit
fi

# Build
echo -n -e "${G} ^-^ Building ${N}"; sleep 0.1;
echo ""
sleep 2
mka recoveryimage

# Credits
echo ""
echo -e "${B} credits :
Do follow me too : https://github.com/Rustmilian
All the best - Rustmilian ${N}"
sleep 3
