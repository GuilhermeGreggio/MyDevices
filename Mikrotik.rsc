# ------------------------------------------------------------ Variavéis
  # Usuário
    :local user_input do={:return}
    :put "\r\nQual usuário você deseja configurar?"
    :local user [$user_input]

  # Senha usuário
    :local password_input do={:return}
    :put "\r\nQual senha você deseja configurar?"
    :local password [$password_input]

  # ID do NextDNS
    :local nextDNS_input do={:return}
    :put "\r\nQual o ID do NextDNS?"
    :local nextDNS [$nextDNS_input]

# ------------------------------------------------------------ Configurações Variáveis

  # Autenticação PPPoE
    /interface pppoe-client 
      add name=pppoe.desktop user=pppoe@.com.br password=senha interface=ether1 add-default-route=yes max-mtu=1492 default-route-distance=1 disabled=no

# Bridge
  /interface bridge
    add name=bridge-dados mtu=1500
    port add bridge=bridge-dados interface=ether3
    port add bridge=bridge-dados interface=ether4
    port add bridge=bridge-dados interface=ether5


# DHCP
  /ip address
    add address=10.0.0.1/24 network=10.0.0.0 interface=bridge-dados
  /ip pool
    add name="dhcp_pool_dados" ranges=10.0.0.2-10.0.0.254
  /ip dhcp-server network
    add address=10.0.0.0/24 gateway=10.0.0.1 dns-server="" wins-server="" ntp-server="" caps-manager="" dhcp-option=""
  /ip dhcp-server
    add name="dhcp-dados" interface=bridge-dados lease-time=1h address-pool=dhcp_pool_dados authoritative=yes use-radius=no disabled=no
  /ip firewall nat
    add chain=srcnat action=masquerade log=no log-prefix=""

  # Comentários de Interfaces
    /interface
    # Ethernet
      set ether1 comment="UPLINK 1"

  # Interface List
    # WAN
      /interface list
      add name=WAN comment="Preset"
      # Ethernet WAN
        member add list=WAN interface=ether1 comment="Preset"
      # PPPoE WAN
        :foreach i in [/interface find type=pppoe-out] do {/interface list member add interface=$i list=WAN comment="Preset"}

    # LAN
      /interface list
      add name=LAN comment="Preset"
      # Ethernet LAN diferente de ether1
        :foreach i in [/interface find type=ether name!=ether1] do {/interface list member add interface=$i list=LAN comment="Preset"}
      # Bridge LAN
        :foreach i in [/interface find type=bridge] do {/interface list member add interface=$i list=LAN comment="Preset"}

# ------------------------------------------------------------ Configurações Padrões

  # Firewall
    # Address List
      /ip firewall address-list 

      # DNS
        add address=45.90.28.0 comment="Preset: DNS" list=DNS
        add address=45.90.30.0 comment="Preset: DNS" list=DNS

      # NTP
        add address=a.ntp.br comment="Preset: NTP" list=NTP
        add address=b.ntp.br comment="Preset: NTP" list=NTP

      # IPs que não podem ser roteados globalmente (Bogon)
        add address=0.0.0.0/8 comment="Preset: RFC6890" list=raw_not_global_ipv4 
        add address=10.0.0.0/8 comment="Preset: RFC6890" list=raw_not_global_ipv4 
        add address=169.254.0.0/16 comment="Preset: RFC6890" list=raw_not_global_ipv4 
        add address=172.16.0.0/12 comment="Preset: RFC6890" list=raw_not_global_ipv4
        add address=192.168.0.0/16 comment="Preset: RFC6890" list=raw_not_global_ipv4 
        add address=198.18.0.0/15 comment="Preset: RFC6890 benchmark" list=raw_not_global_ipv4
        add address=127.0.0.0/8 comment="Preset: RFC6890" list=raw_not_global_ipv4
        add address=192.0.0.0/24 comment="Preset: RFC6890" list=raw_not_global_ipv4
        add address=192.0.2.0/24 comment="Preset: RFC6890" list=raw_not_global_ipv4
        add address=198.51.100.0/24 comment="Preset: RFC6890" list=raw_not_global_ipv4
        add address=203.0.113.0/24 comment="Preset: RFC6890" list=raw_not_global_ipv4
        add address=240.0.0.0/4 comment="Preset: RFC6890 reserved" list=raw_not_global_ipv4
        add address=192.88.99.0/24 comment="Preset: 6to4 relay Anycast [RFC 3068]" list=raw_not_global_ipv4
        add address=255.255.255.255/32 comment="Preset: RFC6890" list=raw_not_global_ipv4 
        add address=224.0.0.0/4 comment="Preset: RFC6890" list=raw_not_global_ipv4

    # Filter
      /ip firewall filter 
      # Forward (Protegendo a LAN)
        add chain=forward action=fasttrack-connection comment="Preset: Established e Related" connection-state=established,related
        add chain=forward action=drop comment="Preset: Drop invalid" connection-state=invalid
        add chain=forward action=drop comment="Preset: Drop incoming packets that are not NAT`ted" connection-state=new connection-nat-state=!dstnat in-interface-list=WAN

      # Input (Protegendo o roteador) 
        add chain=input action=fasttrack-connection comment="Preset: Established e Related" connection-state=established,related in-interface-list=WAN
        add chain=input action=drop comment="Preset: Drop invalid" connection-state=invalid in-interface-list=WAN
        add chain=input action=accept comment="Preset: DNS DoH" protocol=tcp src-address-list=DNS src-port=443 in-interface-list=WAN
        add chain=input action=accept comment="Preset: DNS RAW" protocol=udp src-address-list=DNS src-port=53 in-interface-list=WAN
        add chain=input action=accept comment="Preset: ICMP" protocol=icmp in-interface-list=WAN
        add chain=input action=accept comment="Preset: NTP" protocol=udp src-address-list=NTP dst-port=123 in-interface-list=WAN
        add chain=input action=drop comment="Preset: Drop final Input" in-interface-list=WAN

    # RAW
      /ip firewall raw

      # Proteção contra Bogon IPv4
        add action=accept chain=prerouting comment="Preset: accept DHCP discover" dst-address=255.255.255.255 dst-port=67 in-interface-list=LAN protocol=udp src-address=0.0.0.0 src-port=68
        add action=drop chain=prerouting comment="Preset: drop bogon IP's as source" src-address-list=raw_not_global_ipv4 in-interface-list=WAN
        add action=drop chain=prerouting comment="Preset: drop bogon IP's as destiny" dst-address-list=raw_not_global_ipv4 in-interface-list=WAN
        add action=drop chain=prerouting comment="Preset: drop bad UDP" port=0 protocol=udp in-interface-list=WAN
        add action=jump chain=prerouting comment="Preset: jump to ICMP chain" jump-target=icmp4 protocol=icmp
        add action=jump chain=prerouting comment="Preset: jump to TCP chain" jump-target=bad_tcp protocol=tcp
        add action=accept chain=prerouting comment="Preset: accept everything else from LAN" in-interface-list=LAN
        add action=accept chain=prerouting comment="Preset: accept everything else from WAN" in-interface-list=WAN
        add action=drop chain=prerouting comment="Preset: drop the rest"

      # Filtro TCP
        add action=drop chain=bad_tcp comment="Preset: TCP flag filter" protocol=tcp tcp-flags=!fin,!syn,!rst,!ack
        add action=drop chain=bad_tcp comment="Preset: TCP flag filter" protocol=tcp tcp-flags=fin,syn
        add action=drop chain=bad_tcp comment="Preset: TCP flag filter" protocol=tcp tcp-flags=fin,rst
        add action=drop chain=bad_tcp comment="Preset: TCP flag filter" protocol=tcp tcp-flags=fin,!ack
        add action=drop chain=bad_tcp comment="Preset: TCP flag filter" protocol=tcp tcp-flags=fin,urg
        add action=drop chain=bad_tcp comment="Preset: TCP flag filter" protocol=tcp tcp-flags=syn,rst
        add action=drop chain=bad_tcp comment="Preset: TCP flag filter" protocol=tcp tcp-flags=rst,urg
        add action=drop chain=bad_tcp comment="Preset: TCP port 0 drop" port=0 protocol=tcp

      # Filtro ICMP
        add action=accept chain=icmp4 comment="Preset: echo reply" icmp-options=0:0 limit=5,10:packet protocol=icmp
        add action=accept chain=icmp4 comment="Preset: net unreachable" icmp-options=3:0 protocol=icmp
        add action=accept chain=icmp4 comment="Preset: host unreachable" icmp-options=3:1 protocol=icmp
        add action=accept chain=icmp4 comment="Preset: protocol unreachable" icmp-options=3:2 protocol=icmp
        add action=accept chain=icmp4 comment="Preset: port unreachable" icmp-options=3:3 protocol=icmp
        add action=accept chain=icmp4 comment="Preset: fragmentation needed" icmp-options=3:4 protocol=icmp
        add action=accept chain=icmp4 comment="Preset: echo" icmp-options=8:0 limit=5,10:packet protocol=icmp
        add action=accept chain=icmp4 comment="Preset: time exceeded " icmp-options=11:0-255 protocol=icmp
        add action=drop chain=icmp4 comment="Preset: drop other icmp" protocol=icmp

  # Certificado SSL para o Webfig
    /certificate 
    add name=webfig common-name=webfig key-size=2048 days-valid=5242
    sign webfig
    :delay 10s;

  # NTP
    /system
    clock set time-zone-name=Brazil/East
    ntp client set enabled=yes
    ntp client set primary-ntp=200.160.0.8
    ntp client set secondary-ntp=200.189.40.8

  # Logging
    /system logging
    set topics=warning action=disk numbers=0
    set topics=error action=disk numbers=1
    set topics=info action=disk numbers=2
    set topics=critical action=disk numbers=3
    action set disk disk-lines-per-file=60000 disk-file-count=5 disk-file-name=Log

  # Protocolos de Acesso
    /ip service
    set www-ssl disabled=no port=443 certificate=webfig tls-version=only-1.2
    set winbox disabled=no port=8291
    set ssh disabled=no port=22
    disable api,api-ssl,telnet,www,ftp

  # Usuários
    /user

    # Usuários
      add name=$user group=full password=$password disabled=no comment="Preset"
      remove [find where name!=$user]

  # Hardening
    # Desabilitando funções não utilizadas
      /system 
        package disable wireless,mpls,routing,hotspot,ipv6
        script remove [find]
        scheduler remove [find]

      /ip 
        firewall service-port disable ftp,h323,irc,pptp,tftp
        proxy set enabled=no
        socks set enabled=no
        upnp set enabled=no
        cloud set ddns-enabled=no update-time=no

      /tool 
        mac-server ping set enabled=no
        bandwidth-server set enabled=no
        romon set enabled=no

    # Limitando acesso a determinadas funções
      /ip neighbor discovery-settings set discover-interface-list=LAN
      /tool
        mac-server set allowed-interface-list=LAN
        mac-server mac-winbox set allowed-interface-list=LAN
      /system package update set channel=long-term

  # Loop Protect
    /interface 
    ethernet set [find  default-name!="ether1"] loop-protect=on
    bridge set protocol-mode=rstp [find]

  # DNS
    /ip dns
    set servers=45.90.28.0,45.90.30.0
    set allow-remote-requests=no

    # Script para habilitar o DoH (Requer internet pois é necessário importar o certificado)
      /system script
      add name="Habilitar NextDNS DoH (Requer internet)" policy=write dont-require-permissions=no  source="   \
          \_  /tool fetch url=https://curl.se/ca/cacert.pem\r\
          \n      /certificate import file-name=cacert.pem\r\
          \n      /ip dns\r\
          \n        set servers=\"\"\r\
          \n        static add name=dns.nextdns.io address=45.90.28.0 type=A\r\
          \n        static add name=dns.nextdns.io address=45.90.30.0 type=A\r\
          \n        static add name=dns.nextdns.io address=2a07:a8c0:: type=AAAA\r\
          \n        static add name=dns.nextdns.io address=2a07:a8c1:: type=AAAA\r\
          \n        set use-doh-server=\"https://dns.nextdns.io/$nextDNS\" verify-doh-cert=yes"