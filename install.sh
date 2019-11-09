#! /bin/bash
# by Paul
function printhelp(){
    echo "Usage:"
    echo $0" {username} {install|clear|tar} [dest directory]"
}

if [ ! $# -gt 1 ] ;then
    echo $#
    printhelp
    exit 1
fi
if [ "$3" == "" ]; then
    destdir=$(cd `dirname $0`;pwd)
    echo "You did not set dest directory, use $destdir as default."
else
    if [ ! -d $3 ]; then
        echo "Path not exist:"$3
        exit 1
    fi
fi
if [ ! -d /home/$1 ];then
    echo $1" not exist in this system."
    exit 1
fi
username=$1
action=$2
configdir=$destdir
tardir=$(cd $destdir/..;pwd)

if [[ $(ls /home) =~  ${username} ]] ; then
    echo "Your username is "${username}
    userhome=/home/$username
else
    echo $username" is not user of this system"
    exit 1
fi

if [[ $(uname -v) =~ "debian" ]];then
    echo "You are not use Debian system."
    exit 1
fi

case $action in
    "tar")
        echo "Tar configs to $tardir/configs.tar"
        if [ -d $configdir/configs ];then
            rm -r $configdir/configs
        fi
        mkdir $configdir/configs
        cp ${userhome}/.xinitrc  $configdir/configs/xinitrc
        cp ${userhome}/.Xresources $configdir/configs/Xresources
        cp ${userhome}/.bashrc $configdir/configs/bashrc
        cp ${userhome}/.profile $configdir/configs/profile
        cp ${userhome}/.gvimrc $configdir/configs/gvimrc
        cp ${userhome}/.vimrc $configdir/configs/vimrc
        cp ${userhome}/.gtkrc-2.0 $configdir/configs/gtkrc-2.0
        cp -r ${userhome}/.fvwm $configdir/configs/fvwm
        cp -r ${userhome}/.config/fcitx $configdir/configs/fcitx
        cp -r ${userhome}/.config/mimeapps.list $configdir/configs/mimeapps.list
        cp -r ${userhome}/.config/user-dirs.dirs $configdir/configs/user-dirs.dirs
        scriptdir=$(cd `dirname $0`;pwd)
        tardest=${scriptdir##*/}
        cd $scriptdir/..
        tar -cjf $tardir/$tardest.tar $tardest
        ;;
    "clear")
        echo "Just clear current user's configs"
        rm ${userhome}/.xinitrc
        rm ${userhome}/.Xresources
        rm ${userhome}/.bashrc
        rm ${userhome}/.profile
        rm ${userhome}/.gvimrc
        rm ${userhome}/.vimrc
        rm ${userhome}/.gtkrc-2.0
        rm -r ${userhome}/.fvwm
        rm -r ${userhome}/.config/fcitx
        rm  ${userhome}/.config/mimeapps.list
        rm -r ${userhome}/.config/user-dirs.dirs
        ;;
    "install")

        if [ ! -d $configdir/configs ];then
            echo "Can not found configs in the directory $configdir."
            exit 1
        fi
        if [ $(id -u) -eq 0 ]; then
            echo "You are root user, now install some softwares and change some system config..."
            echo "install softwares..."
            #install softwares
            apt-get install xorg fvwm menu pcmanfm conky-all sudo hibernate acpi mpg123 imagemagick xscreensaver emacs vim-gtk fcitx fcitx-table-wubi iceweasel xchm xpdf gimp gthumb vlc audacious recoll libreoffice build-essential automake autoconf m4  cmake bash xdm p7zip xarchiver p7zip-full arj lhasa rpm unrar unrar-free zip axel manpages-zh  minicom libreoffice-l10n-zh-cn xloadimage shadowsocks inetutils-tools net-tools xosview stalonetray volumeicon-alsa git brasero locales global virtualenv pulseaudio enca sdcv archmage mplayer gnome-icon-theme gnome-icon-theme-extras

            # Using nmtui(network manager text user interface) to manage network interface is easy.
            # But you need to note that network manager just work on the interface which is not defined in /etc/network/interfaces，you should comment all the interfaces in /etc/network/interfaces except lo.

            echo "Modify /home/"$username" attribs"
            chown -R ${username}:${username} /home/${username}
            usermod -g ${username} ${username}
            usermod -G sudo ${username}
            echo "Add user "$username" to SUDO group"
            if [ ! -f "/etc/sudoers.bak" ]; then
                cp /etc/sudoers /etc/sudoers.bak
                echo ${username}'  ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
            fi

            echo "Config minicom ..."
            if [ ! -f "/dev/ttyUSB0" ]; then
                ln -sf /dev/ttyUSB0 /dev/modem
            fi
            # use "sudo minicom -s" to config
            # sudo minicom

            echo "Install msfonts..."
            if [ ! -d /usr/share/fonts/msfonts ] ; then
                mkdir /usr/share/fonts/msfonts
                cp -r -f  $configdir/msfonts/* /usr/share/fonts/msfonts/
                cd /usr/share/fonts/msfonts
                #chmod -R 755 ./msfonts
                mkfontscale
                mkfontdir
            fi
            fc-cache -fv
            # subsitute the second "sansserif" to "simsun" in /etc/fonts/conf.d/49-sansserif.conf to sole the problem the Chinese miss display in flash plugin.
            # sudo vim /etc/fonts/conf.d/49-sansserif.conf

            echo "Config timezone to Shanghai"
            #echo "export TZ=""Asia/Shanghai" >> ${userhome}/.profile
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

            echo "Change user to "$username
            su $username
        else
            echo "You are not root,so have no permission to modify systemconfig,but you can change yourself's config. Skip system modify."
            #config desktop env
            cp $configdir/configs/xinitrc ${userhome}/.xinitrc
            cp $configdir/configs/Xresources ${userhome}/.Xresources
            cp $configdir/configs/bashrc ${userhome}/.bashrc
            cp $configdir/configs/profile ${userhome}/.profile
            cp $configdir/configs/gvimrc ${userhome}/.gvimrc
            cp $configdir/configs/vimrc ${userhome}/.vimrc
            cp $configdir/configs/gtkrc-2.0 ${userhome}/.gtkrc-2.0
            if [[ -d $userhome/.config/fcitx ]]; then
                rm -r $userhome/.config/fcitx
            fi
            cp -r $configdir/configs/fcitx ${userhome}/.config/
            if [[ -d $userhome/.fvwm ]]; then
                rm -r $userhome/.fvwm
            fi
            cp -r $configdir/configs/fvwm ${userhome}/.fvwm
            cp -r $configdir/configs/mimeapps.list ${userhome}/mimeapps.list
            cp -r $configdir/configs/user-dirs.dirs ${userhome}/user-dirs.dirs
            mkdir ./tmp
            cd ./tmp
            #Install Flash plugin
            tar xvf $configdir/plugins/install_flash_player_11_linux.i386.tar.gz
            mkdir -p  ${userhome}/.mozilla/plugins
            cp libflashplayer.so ${userhome}/.mozilla/plugins/
            #Install Alipay plugin
            tar xvf $configdir/plugins/aliedit.tar.gz
            /bin/bash ./aliedit.sh

            cd ..
            rm -r ./tmp
            #editor no protocol specified error
            #echo "export XAUTHORITY=${userhome}/.Xauthority" >> ${userhome}/.bashrc
            #Desktop wallpaper images process
            if [ -d $userhome/backgroud-images ]; then
                echo "Change "$userhome"/backgroud-images images's type to PNG"
                cd $userhome/backgroud-images
                for i in $(ls images); do convert "$i" "${i%%.*}.png" ; if  ["${i##*.}" != "png"];then rm "$i" ;fi ;done
            fi
            # set vim as the alias to "emacs -nw" in .bashrc
            echo "Fix the default application for open directory"
            if [[ ! -d "/home/$username/.local/share/applications" ]] ; then
                mkdir -p /home/$username/.local/share/applications
            fi
            xdg-mime default pcmanfm.desktop inode/directory
            echo "git clone the newest emacs config"
            git clone https://github.com/redguardtoo/emacs.d.git ${userhome}/.emacs.d
        fi
        ;;
    *)
        echo "command ${action} is not supported."
        printhelp
        ;;
esac
