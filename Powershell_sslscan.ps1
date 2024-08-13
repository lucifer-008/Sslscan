# Check if the user provided the domain or IP address
param (
    [Parameter(Mandatory=$true)]
    [string]$Domain,

    [int]$Port = 443
)

function Test-SSLProtocol {
    param (
        [string]$Domain,
        [int]$Port,
        [string]$Protocol
    )

    try {
        # Create a TCP connection to the server
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($Domain, $Port)

        # Set the SSL/TLS protocol version
        $sslStream = New-Object System.Net.Security.SslStream(
            $tcpClient.GetStream(),
            $false,
            { $true }
        )

        # Authenticate as client with specified SSL/TLS protocol
        $sslStream.AuthenticateAsClient($Domain, $null, $Protocol, $false)

        # Get SSL/TLS details
        $cipherAlgorithm = $sslStream.CipherAlgorithm
        $cipherStrength = $sslStream.CipherStrength
        $hashAlgorithm = $sslStream.HashAlgorithm
        $hashStrength = $sslStream.HashStrength
        $keyExchangeAlgorithm = $sslStream.KeyExchangeAlgorithm
        $keyExchangeStrength = $sslStream.KeyExchangeStrength

        Write-Output "[$Protocol] Connection established with $Domain on port $Port"
        Write-Output "    Cipher: $cipherAlgorithm ($cipherStrength bits)"
        Write-Output "    Hash: $hashAlgorithm ($hashStrength bits)"
        Write-Output "    Key Exchange: $keyExchangeAlgorithm ($keyExchangeStrength bits)"

        # Close the SSL stream and TCP connection
        $sslStream.Close()
        $tcpClient.Close()
    } catch {
        Write-Output "[$Protocol] Failed to connect: $_"
    }
}

# List of supported SSL/TLS protocols to test
$protocols = @(
    [System.Security.Authentication.SslProtocols]::Ssl3,
    [System.Security.Authentication.SslProtocols]::Tls,
    [System.Security.Authentication.SslProtocols]::Tls11,
    [System.Security.Authentication.SslProtocols]::Tls12,
    [System.Security.Authentication.SslProtocols]::Tls13
)

# Run SSL/TLS scan for the given domain and port
foreach ($protocol in $protocols) {
    Test-SSLProtocol -Domain $Domain -Port $Port -Protocol $protocol
}
