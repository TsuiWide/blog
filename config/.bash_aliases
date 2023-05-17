alias dkupdatebashrc='source ~/.bashrc'

alias dkupdatebashalias='source $DKCONFIGDIR/.bash_aliases'

alias dkcdhome='cd $DKHOMEDIR'

alias dkll='ls -alh'

f_envcheck() {
	if [ -f $DKCONFIGDIR/scripts/dkenvcheck.sh ]; then
		source $DKCONFIGDIR/scripts/dkenvcheck.sh
	else
		echo "$DKCONFIGDIR/scripts/dkenvcheck.sh NOT found!"
	fi
}
alias dkenvcheck=f_envcheck

f_dklntmuxconf() {
	if [ -f $DKSCRIPTSDIR/dklntmuxconf.sh ]; then
		source $DKSCRIPTSDIR/dklntmuxconf.sh
	else
		echo "$DKSCRIPTSDIR/dklntmuxconf.sh NOT found!"
	fi
}
alias dklntmuxconf=f_dklntmuxconf

f_dklnallscripts() {
	if [ -f $DKSCRIPTSDIR/dklnallscripts.sh ]; then
		source $DKSCRIPTSDIR/dklnallscripts.sh
	else
		echo "$DKSCRIPTSDIR/dklnallscripts.sh NOT found!"
	fi
}
alias dklnallscripts=f_dklnallscripts
