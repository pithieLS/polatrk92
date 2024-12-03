# Define interfaces
admin_if = "em0"          # Administration LAN
server_if = "em1"         # Server LAN
employee_if = "em2"       # Employee LAN
wan_if = "em3"            # WAN / Internet

# Define networks
admin_net = "192.168.42.0/26"
server_net = "192.168.42.64/26"
employee_net = "192.168.42.128/26"

# Define services and ports
web_ports = "{ 80, 443 }"        # HTTP and HTTPS
icmp_types = "echoreq"           # Ping (ICMP Echo Request)

# Default block policy
set block-policy drop
block all

# Allow stateful traffic
set state-policy if-bound
set skip on lo

# NAT for internet access
match out on $wan_if from { $admin_net, $server_net, $employee_net } to any nat-to ($wan_if)

# Administration LAN: Allow all traffic to Server LAN
pass in on $admin_if from $admin_net to $server_net keep state
# Employee LAN: Allow HTTP/HTTPS to Server LAN
pass in on $employee_if from $employee_net to $server_net port $web_ports keep state

# Allow all LANs to access the internet
pass out on $wan_if from { $admin_net, $server_net, $employee_net } to any keep state

# Allow ping between subnets
pass in on { $admin_if, $server_if, $employee_if } inet proto icmp icmp-type $icmp_types keep state

# Allow DHCP
pass in on { $admin_if, $server_if, $employee_if } proto udp from any port 67 to any port 68 keep state

# Allow DNS
pass in on { $admin_if, $server_if, $employee_if } proto udp to any port 53 keep state
pass in on { $admin_if, $server_if, $employee_if } proto tcp to any port 53 keep state
