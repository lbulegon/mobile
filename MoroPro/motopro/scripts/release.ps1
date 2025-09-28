# Script de Release para MoroPro
# Uso: .\scripts\release.ps1 -Version "1.1.0" -Message "Adicionadas novas funcionalidades"

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$true)]
    [string]$Message
)

Write-Host "🚀 Iniciando processo de release para versão $Version" -ForegroundColor Green

# 1. Verificar se estamos na branch main
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "❌ Erro: Você deve estar na branch main para fazer release" -ForegroundColor Red
    exit 1
}

# 2. Verificar se há mudanças não commitadas
$status = git status --porcelain
if ($status) {
    Write-Host "❌ Erro: Há mudanças não commitadas. Faça commit antes de continuar." -ForegroundColor Red
    exit 1
}

# 3. Atualizar versão no pubspec.yaml
Write-Host "📝 Atualizando versão no pubspec.yaml..." -ForegroundColor Yellow
$pubspecContent = Get-Content "pubspec.yaml" -Raw
$newVersion = "version: $Version+1"
$pubspecContent = $pubspecContent -replace "version: \d+\.\d+\.\d+\+\d+", $newVersion
Set-Content "pubspec.yaml" $pubspecContent

# 4. Executar testes
Write-Host "🧪 Executando testes..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro: Testes falharam. Corrija os problemas antes de continuar." -ForegroundColor Red
    exit 1
}

# 5. Fazer commit das mudanças
Write-Host "💾 Fazendo commit das mudanças..." -ForegroundColor Yellow
git add pubspec.yaml
git commit -m "Bump version to $Version"

# 6. Criar tag
Write-Host "🏷️ Criando tag v$Version..." -ForegroundColor Yellow
git tag -a "v$Version" -m "Release version $Version - $Message"

# 7. Push das mudanças e tag
Write-Host "📤 Enviando mudanças para o repositório remoto..." -ForegroundColor Yellow
git push origin main
git push origin "v$Version"

# 8. Build de release (opcional)
$buildRelease = Read-Host "Deseja fazer build de release? (y/n)"
if ($buildRelease -eq "y" -or $buildRelease -eq "Y") {
    Write-Host "🔨 Fazendo build de release..." -ForegroundColor Yellow
    flutter build apk --release
    Write-Host "✅ Build concluído! APK disponível em build/app/outputs/flutter-apk/" -ForegroundColor Green
}

Write-Host "🎉 Release $Version criado com sucesso!" -ForegroundColor Green
Write-Host "📋 Próximos passos:" -ForegroundColor Cyan
Write-Host "   - Atualize o CHANGELOG.md com as mudanças desta versão" -ForegroundColor White
Write-Host "   - Crie uma release no GitHub/GitLab se necessário" -ForegroundColor White
Write-Host "   - Distribua o APK/IPA para testadores" -ForegroundColor White

