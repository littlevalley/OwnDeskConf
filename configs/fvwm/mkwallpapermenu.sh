for file in ~/.fvwm/images/bgicons/*.png; do filename=${file##*/}; echo "+ \"${filename%%.*}%bgicons/${file##*/}%\" SetBG ${file##*/}"; done
