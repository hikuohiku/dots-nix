function FindProxyForURL(url, host) {
  if (shExpMatch(host, "*.lab")) {
    return "SOCKS5 127.0.0.1:1080; DIRECT";
  }
  return "DIRECT";
}
