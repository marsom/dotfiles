export KREW_ROOT=${KREW_ROOT:-$HOME/.krew}
if [ -d ${KREW_ROOT}/bin ]; then
	export PATH=${KREW_ROOT}/bin:$PATH
fi
