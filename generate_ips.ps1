$domains = @(
    "www.instagram.com",
    "b.i.instagram.com",
    "z-p42-chat-e2ee-ig.facebook.com",
    "help.instagram.com"
)

$dnsServers = @(
    "8.8.8.8","8.8.4.4",
    "1.1.1.1","1.0.0.1",
    "9.9.9.9","149.112.112.112",
    "208.67.222.222","208.67.220.220",
    "94.140.14.14","94.140.15.15"
)

$allIPs = @()

foreach ($domain in $domains) {
    foreach ($dns in $dnsServers) {
        try {
            $result = Resolve-DnsName -Server $dns -Name $domain -ErrorAction Stop |
                Where-Object { $_.IPAddress -match "^\d+\.\d+\.\d+\.\d+$" } |
                Select-Object -ExpandProperty IPAddress

            $allIPs += $result
        } catch {}
    }
}

$uniqueIPs = $allIPs | Sort-Object -Unique

$aliveIPs = @()

foreach ($ip in $uniqueIPs) {
    try {
        $tcp = Test-NetConnection -ComputerName $ip -Port 443 -WarningAction SilentlyContinue
        if ($tcp.TcpTestSucceeded) {
            $aliveIPs += $ip
        }
    } catch {}
}

$aliveIPs | Out-File -Encoding ascii "instagram_ips.txt"
