--- a/package/network/services/dnsmasq/Makefile
+++ b/package/network/services/dnsmasq/Makefile
@@ -66,8 +66,7 @@
   TITLE += (with DNSSEC, DHCPv6, Auth DNS, IPset, Nftset, Conntrack, NO_ID enabled by default)
   DEPENDS+=+PACKAGE_dnsmasq_full_dnssec:libnettle \
 	+PACKAGE_dnsmasq_full_ipset:kmod-ipt-ipset \
-	+PACKAGE_dnsmasq_full_conntrack:libnetfilter-conntrack \
-	+PACKAGE_dnsmasq_full_nftset:nftables-json
+	+PACKAGE_dnsmasq_full_conntrack:libnetfilter-conntrack
   VARIANT:=full
   PROVIDES:=dnsmasq
 endef
@@ -187,6 +186,11 @@
 	$(INSTALL_DIR) $(1)/etc/uci-defaults
 	$(INSTALL_BIN) ./files/50-dnsmasq-migrate-resolv-conf-auto.sh $(1)/etc/uci-defaults
 	$(INSTALL_BIN) ./files/50-dnsmasq-migrate-ipset.sh $(1)/etc/uci-defaults
+	$(INSTALL_DIR) $(1)/usr/lib
+	$(INSTALL_BIN) $(STAGING_DIR)/usr/lib/libnftables.so.1 $(1)/usr/lib/libnftables.so.1
+	$(INSTALL_BIN) $(STAGING_DIR)/usr/lib/libjansson.so.4 $(1)/usr/lib/libjansson.so.4
+	$(INSTALL_BIN) $(STAGING_DIR)/usr/lib/libnftnl.so.11 $(1)/usr/lib/libnftnl.so.11
+	$(INSTALL_BIN) $(STAGING_DIR)/usr/lib/libmnl.so.0 $(1)/usr/lib/libmnl.so.0
 endef
 
 Package/dnsmasq-dhcpv6/install = $(Package/dnsmasq/install)


--- a/package/network/services/dnsmasq/files/dnsmasq.init
+++ b/package/network/services/dnsmasq/files/dnsmasq.init
@@ -1251,7 +1251,7 @@
 	[ -n "$instance_ifc" ] && network_get_device instance_netdev "$instance_ifc" &&
 		[ -n "$instance_netdev" ] && procd_set_param netdev $instance_netdev
 
-	procd_add_jail dnsmasq ubus log
+
 	procd_add_jail_mount $CONFIGFILE $DHCPBOGUSHOSTNAMEFILE $DHCPSCRIPT $DHCPSCRIPT_DEPENDS
 	procd_add_jail_mount $EXTRA_MOUNT $RFC6761FILE $TRUSTANCHORSFILE
 	procd_add_jail_mount $dnsmasqconffile $dnsmasqconfdir $resolvdir $user_dhcpscript
@@ -1264,6 +1264,20 @@
 	[ -e "$hostsfile" ] && procd_add_jail_mount $hostsfile
 
 	procd_close_instance
+	config_get_bool dns_redirect "$cfg" dns_redirect 0
+	config_get dns_port "$cfg" port 53
+	if [ "$dns_redirect" = 1 ]; then
+	if [ -n "$(command -v nft)" ]; then
+		nft add table inet dnsmasq
+		nft add chain inet dnsmasq prerouting "{ type nat hook prerouting priority -105; policy accept; }"
+		nft add rule inet dnsmasq prerouting "meta nfproto { ipv4, ipv6 } udp dport 53 counter redirect to :$dns_port comment \"DNSMASQ HIJACK\""
+	else
+		iptables -t nat -A PREROUTING -m comment --comment "DNSMASQ" -p udp --dport 53 -j REDIRECT --to-ports $dns_port
+		iptables -t nat -A PREROUTING -m comment --comment "DNSMASQ" -p tcp --dport 53 -j REDIRECT --to-ports $dns_port
+		[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -m comment --comment "DNSMASQ" -p udp --dport 53 -j REDIRECT --to-ports $dns_port
+		[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -m comment --comment "DNSMASQ" -p tcp --dport 53 -j REDIRECT --to-ports $dns_port
+	fi
+	fi
 }
 
 dnsmasq_stop()
@@ -1280,6 +1294,20 @@
 
 	rm -f ${BASEDHCPSTAMPFILE}.${cfg}.*.dhcp
 }
+iptables_clear()
+{
+	config_get dns_port "$cfg" port 53
+	iptables -t nat -D PREROUTING -m comment --comment "DNSMASQ" -p udp --dport 53 -j REDIRECT --to-ports $dns_port 2>"/dev/null"
+	iptables -t nat -D PREROUTING -m comment --comment "DNSMASQ" -p tcp --dport 53 -j REDIRECT --to-ports $dns_port 2>"/dev/null"
+	[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -D PREROUTING -m comment --comment "DNSMASQ" -p udp --dport 53 -j REDIRECT --to-ports $dns_port 2>"/dev/null"
+	[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -D PREROUTING -m comment --comment "DNSMASQ" -p tcp --dport 53 -j REDIRECT --to-ports $dns_port 2>"/dev/null"
+}
+
+nftables_clear()
+{
+	! nft --check list table inet dnsmasq > "/dev/null" 2>&1 || \
+		nft delete table inet dnsmasq
+}
 
 add_interface_trigger()
 {
@@ -1352,6 +1380,7 @@
 }
 
 reload_service() {
+	[ -n "$(command -v nft)" ] && nftables_clear || iptables_clear
 	rc_procd start_service "$@"
 	procd_send_signal dnsmasq "$@"
 }
@@ -1378,4 +1407,5 @@
 	else
 		config_foreach dnsmasq_stop dnsmasq
 	fi
+	[ -n "$(command -v nft)" ] && nftables_clear || iptables_clear
 }
