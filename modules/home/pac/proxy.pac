function FindProxyForURL(url, host) {
  // すべての *.lab をSOCKS5へ
  if (
    isInNet(myIpAddress(), "10.28.0.0", "255.255.0.0") &&
    shExpMatch(host, "*.lab")
  ) {
    return "SOCKS5 127.0.0.1:1080";
  }
  // それ以外は直接
  return "DIRECT";
}
