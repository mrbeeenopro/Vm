#!/bin/bash
[ -z "$HOME" ] && [ -d "/home/container" ] && export HOME="/home/container"
export HOSTNAME="$(cat /proc/sys/kernel/hostname)"

# Copyright (c) by H3L2F. All rights reserved.
# https://h3l2f.site

# >> ⚙️ User-Configuration <<
install_path="$HOME/cache/$(echo "$HOSTNAME" | md5sum | sed 's+ .*++g')"
shared_path="$HOME/shared"
user_passwd="$HOSTNAME"
retailer_mode=false
DOCKER_RUN="$install_path/dockerd \
    --kill-on-exit -r $install_path -b /dev -b /proc -b /sys -b /tmp \
    -b $install_path/etc/hostname:/proc/sys/kernel/hostname \
    -b $install_path$HOME/shared:$shared_path \
    -b $install_path:$install_path /bin/sh -c"
osVer="3.21"
detailOsVer="$osVer.0"

getarch() {
  case "$(uname -m)" in
  x86_64)
    [ -z "$1" ] && echo "x86_64" || echo "$1"
    ;;
  aarch64)
    [ -z "$2" ] && echo "aarch64" || echo "$2"
    ;;
  *)
    echo "Unsupport architecture: $(uname -m)"
    exit 1
    ;;
  esac
}

if_x86_64() { [ "$(uname -m)" == "x86_64" ] && echo "$1"; }

# [ 🖧 Mirrors ]
mirror_alpine="https://dl-cdn.alpinelinux.org/alpine/v$osVer/releases/$(getarch)/alpine-minirootfs-$detailOsVer-$(getarch).tar.gz"
mirror_proot="https://github.com/proot-me/proot/releases/download/v5.3.0/proot-v5.3.0-$(getarch)-static"

d.stat() { echo -ne "\033[1;37m==> \033[1;34m$@\033[0m\n"; }
d.dftr() { echo -ne "\033[1;33m!!! DISABLED FEATURE: \033[1;31m$@ \033[1;33m!!!\n"; }
d.warn() { echo -ne "\033[1;33mwarning: \033[1;31m$@\[033;0m\n"; }

die() {
  echo -ne "\n\033[41m               \033[1;37mA FATAL ERROR HAS OCCURED               \033[0m\n"
  sleep 5
  exit 1
}

printlogo() {
  printf "[[\033[94mH3L2F - Powered by \033[32mno\033[93mVNC\033[0m]]\n"
}

clear

fcr() {
  echo "[$( date +%H:%M:%S ) INFO]: [Lemem-vnc] done!"
  NO_FORMAT="\033[0m"
  C_PURPLE3="\033[38;5;56m"
  echo -e "${C_PURPLE3}                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                        Ò¥DDDbÒ                  èÓÓÓÓë                        
                      ðdFDDDDFFb               ýÓÓÞÞÞÞÞèÙ                      
                    ¶$ëëFDDDDDDDFÒ           ÙèÓÞÞÞÞÞÞÞÞÞèý                    
                   Üëëë$$ÒFDDDDDDFFÒ       $èÓÞÞÞÞÞÞÞÞÞÞÞÞÓý                   
                 é$ëëëëëëëëbDDDDDDDDFb   ÙÓÓÓÞÞÞÞÞÓèèÓÞÞÞÞÞÞÓè                 
               éÜëëëëëëë$8  Ö¥DDDDDDDD¥ÞèÓÞÞÞÞÞÓÓèë  dÓÓÞÞÞÞÞÞÓý               
             é$$$ëëëëë$Ú      bFFDDDDDDFbÞÞÞÞÞÓèý      ýÓÞÞÞÓÓÓÞÞÓ             
           8$ëëëëëëëëÜ          ÿFDDDDDDDFbÓÓèÙ          ýÓÓÞFDDDD¥Ò           
           8ëëëëëëë$8             ÿ¥DDDDDDDFÒ             ÞbFDDDDDDb           
           ø$ëëëëëëë$Ü          ÙèÓÓÒFDDDDDDFFÒ          bDDDDDDDFDÒ           
             ð$ëëëëëë$$8      ýÓÓÞÞÞÓÓbFDDDDDDF¥Ò      ÒFDDDDDDFD¥             
               ð$ëëëëëë$$é   ÓÓÓÞÞÞÞÞÓýè¥FDDDDDDDFÓ  ÒFDDDDDDFFÒ               
                 8$ëëëëëëë$ÙÓÓÞÞÞÞÓÓèý   ÿ¥FDDDDDDD¥¥DDDDDDDF¥                 
                   Ü$ëëëë$ë$$ýÓÓÞÓÓÙ       ÞFDDDDDDDDDDDDDDFÿ                  
                    ¶Ü$ëëëëëë$dÓÓý           bFDDDDDDDDFDFÒ                    
                      ø$ëëëëëëdè               bDDDDDDDFÒ                      
                        é$ëë$$Ü                  bDDFF¥                        
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               
                                                                               ${NO_FORMAT}"
}

bootstrap_system() {
  # Printing the watermark
  printlogo

  _CHECKPOINT=$PWD

  mkdir -p /tmp/.X11-unix
  chmod 1777 /tmp/.X11-unix


  d.stat "Initializing the Alpine rootfs image..."
  curl -L "$mirror_alpine" -o a.tar.gz && tar -xf a.tar.gz || die
  rm -rf a.tar.gz

  d.stat "Downloading a Docker Daemon..."
  curl -L "$mirror_proot" -o dockerd || die
  chmod +x dockerd

  d.stat "Bootstrapping system..."
  touch etc/{passwd,shadow,groups}

  # copy shit
  cp /etc/resolv.conf "$install_path/etc/resolv.conf" -v
  cp /etc/hosts "$install_path/etc/hosts" -v
  cp /etc/localtime "$install_path/etc/localtime" -v
  cp /etc/passwd "$install_path"/etc/passwd -v
  cp /etc/group "$install_path"/etc/group -v
  sed -i "s+1000+$(id -u)+g" "$install_path/etc/"{passwd,group}
  sed -i "s+$HOME+$install_path$HOME+g" "$install_path/etc/passwd"
  cp /etc/nsswitch.conf "$install_path"/etc/nsswitch.conf -v
  echo "h3l2f" >"$install_path"/etc/hostname
  mkdir -p "$install_path$HOME"

  ./dockerd -r . -b /dev -b /sys -b /proc -b /tmp \
    --kill-on-exit -w $HOME /bin/sh -c "apk update && apk add bash kitty kitty-kitten konsole xorg-server git python3 py3-pip py3-numpy openssl \
      xinit xvfb fakeroot firefox tigervnc xfce4 xfce4-terminal lightdm-gtk-greeter dbus openrc font-noto mesa-dri-gallium font-jetbrains-mono \
      py3-urllib3 py3-typing-extensions py3-redis py3-cparser py3-idna py3-charset-normalizer py3-certifi gcompat \
      py3-requests py3-cffi py3-cryptography py3-jwcrypto curl neofetch $(if_x86_64 virtualgl) \
        --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing \
        --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
        --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main; \
    git clone https://github.com/h3l2f/noVNC1 /usr/lib/noVNC && \
    cd /usr/lib/noVNC
    openssl req -x509 -sha256 -days 356 -nodes -newkey rsa:2048 -subj '/CN=$(curl -L checkip.pterodactyl-installer.se)/C=US/L=San Fransisco' -keyout self.key -out self.crt & \
    cp vnc.html index.html && \
    ln -s /usr/bin/fakeroot /usr/bin/sudo && \
    pip install websockify --break-system-packages && \
    mkdir -p $HOME/.vnc && echo '$user_passwd' | vncpasswd -f > $HOME/.vnc/passwd && \
    firefox -CreateProfile h3l2f --headless && \
    curl -L 'https://github.com/yokoffing/Betterfox/raw/main/user.js' -o \"$HOME/.mozilla/firefox/\$(ls '$HOME/.mozilla/firefox' | grep h3l2f)/user.js\";\
    git clone https://github.com/h3l2f/lememStuff /home/container/stuff && \
    cd /home/container/stuff && \
    mkdir /home/container/.config && \
    tar xvzf config.tar.gz -C /home/container/.config && \
    cp lemem-wallpaper.png /usr/share/backgrounds/xfce"
  sed -i "s+Profile=1+Profile=0+g" "$install_path$HOME/.mozilla/firefox/profiles.ini"
  sed -i "1aexport USER=root" "$install_path/usr/bin/fakeroot"
  cat >"$install_path$HOME/.vnc/config" <<EOF
session=xfce
geometry=1600x800
rfbport=5901
EOF
}

run_system() {
  #!/bin/bash

  # Check if file exists
  if [ -f "$HOME/.do-not-start" ]; then
    rm -rf "$HOME/.do-not-start"
    cp /etc/resolv.conf "$install_path/etc/resolv.conf" -v
    $DOCKER_RUN /bin/sh
    exit
  fi

  # Function to start NoVNC and VNC server
  start_services() {
    # Starting NoVNC
    $install_path/dockerd --kill-on-exit -r $install_path -b /dev -b /proc -b /sys -b /tmp -w "/usr/lib/noVNC" /bin/sh -c \
      "./utils/novnc_proxy --vnc localhost:5901 --listen 0.0.0.0:$SERVER_PORT --cert self.crt --key self.key" &>/dev/null &

    # Set up VNCPasswd
    chmod 0600 "$install_path$HOME/.vnc/passwd" # prerequisite

    $DOCKER_RUN "export PATH=$install_path/bin:$install_path/usr/bin:$PATH HOME=$install_path$HOME LD_LIBRARY_PATH='$install_path/usr/lib:$install_path/lib:/usr/lib:/usr/lib64:/lib64:/lib'; \
      cd $install_path$HOME; \
      export MOZ_DISABLE_CONTENT_SANDBOX=1 \
      MOZ_DISABLE_SOCKET_PROCESS_SANDBOX=1 \
      MOZ_DISABLE_RDD_SANDBOX=1 \
      MOZ_DISABLE_GMP_SANDBOX=1 \
      HOME='$install_path$HOME' \
      HOSTNAME=h3l2f; \
      $(if_x86_64 "vglrun -d egl") vncserver :0" &>/dev/null &
    sleep 1
    fcr
  }

  # Keep the service alive indefinitely
  while true; do
    start_services
    sleep 86400 # Sleep for 24 hours, adjust as needed
  done
}


cd "$install_path" || {
  mkdir -p "$install_path"
  cd "$install_path"
}
if [ -d "bin" ]; then
  run_system
else
  bootstrap_system
fi
