# remove proxy variable from environment
function proxy_off() {
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset http_proxy
  unset https_proxy
  unset no_proxy
}
