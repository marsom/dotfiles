# remove proxy variable from environment
function proxy_off() {
  unset http_proxy
  unset https_proxy
  unset no_proxy
}