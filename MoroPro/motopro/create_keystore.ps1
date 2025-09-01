# Script para gerar keystore no PowerShell
Write-Host "Gerando keystore para assinatura de producao..." -ForegroundColor Green

# Tentar encontrar o Java
$javaPath = $null

# Verificar se java está no PATH
try {
    $javaPath = (Get-Command java -ErrorAction Stop).Source
    Write-Host "Java encontrado no PATH: $javaPath" -ForegroundColor Yellow
} catch {
    Write-Host "Java não encontrado no PATH, procurando em locais comuns..." -ForegroundColor Yellow
    
    # Locais comuns do Java no Windows
    $possiblePaths = @(
        "C:\Program Files\Java\jdk-17\bin\keytool.exe",
        "C:\Program Files\Java\jdk-11\bin\keytool.exe",
        "C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot\bin\keytool.exe",
        "C:\Program Files\OpenJDK\jdk-17\bin\keytool.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $javaPath = $path
            Write-Host "Java encontrado em: $javaPath" -ForegroundColor Green
            break
        }
    }
}

if (-not $javaPath) {
    Write-Host "ERRO: Java não encontrado. Instale o Java JDK primeiro." -ForegroundColor Red
    Write-Host "Você pode baixar em: https://adoptium.net/" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Gerar keystore
Write-Host "Gerando keystore..." -ForegroundColor Yellow

$keystorePath = "android\app\upload-keystore.jks"
$arguments = @(
    "-genkey",
    "-v",
    "-keystore", $keystorePath,
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-alias", "upload",
    "-storepass", "motopro123",
    "-keypass", "motopro123",
    "-dname", "CN=MotoPro, OU=Development, O=YourCompany, L=YourCity, S=YourState, C=BR"
)

try {
    & $javaPath $arguments
    
    if (Test-Path $keystorePath) {
        Write-Host "`nKeystore gerado com sucesso!" -ForegroundColor Green
        Write-Host "Arquivo: $keystorePath" -ForegroundColor Cyan
        Write-Host "`nIMPORTANTE: Guarde este arquivo em local seguro!" -ForegroundColor Red
        Write-Host "Senha do keystore: motopro123" -ForegroundColor Yellow
    } else {
        Write-Host "ERRO: Keystore não foi criado!" -ForegroundColor Red
    }
} catch {
    Write-Host "ERRO ao gerar keystore: $_" -ForegroundColor Red
}

Write-Host "`nPressione Enter para continuar..."
Read-Host
