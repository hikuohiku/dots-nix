function FindProxyForURL(url, host) {
  if (
    // isInNet(myIpAddress(), "10.28.0.0", "255.255.192.0") &&
    dnsDomainIs(host, ".lab")
  ) {
    return "SOCKS5 127.0.0.1:1080; DIRECT";
  }
  return "DIRECT";
}
