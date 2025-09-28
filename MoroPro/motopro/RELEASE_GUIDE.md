# Guia de Release - MoroPro

## Estratégias de Versionamento

### 1. Versionamento Semântico
- **MAJOR (1.0.0)**: Mudanças incompatíveis
- **MINOR (0.1.0)**: Novas funcionalidades compatíveis  
- **PATCH (0.0.1)**: Correções de bugs

### 2. Fluxo de Trabalho Recomendado

#### Para Novas Funcionalidades (MINOR):
1. Criar branch `feature/nome-da-funcionalidade`
2. Desenvolver e testar
3. Fazer merge para `develop`
4. Testes de integração
5. Merge para `main`
6. Criar release

#### Para Correções (PATCH):
1. Criar branch `hotfix/descricao-do-bug`
2. Corrigir o problema
3. Testar a correção
4. Merge direto para `main`
5. Criar release

### 3. Checklist de Release

#### Antes do Release:
- [ ] Todas as funcionalidades estão implementadas
- [ ] Testes unitários passando
- [ ] Testes de integração passando
- [ ] Documentação atualizada
- [ ] CHANGELOG.md atualizado
- [ ] Código revisado

#### Durante o Release:
- [ ] Atualizar versão no `pubspec.yaml`
- [ ] Executar script de release
- [ ] Verificar se a tag foi criada
- [ ] Fazer build de release

#### Após o Release:
- [ ] Criar release no GitHub/GitLab
- [ ] Notificar equipe sobre a nova versão
- [ ] Atualizar documentação de deploy
- [ ] Monitorar feedback dos usuários

### 4. Comandos Úteis

```bash
# Ver todas as versões
git tag -l

# Ver detalhes de uma versão
git show v1.1.0

# Comparar versões
git diff v1.0.0..v1.1.0

# Voltar para uma versão específica
git checkout v1.0.0

# Criar branch a partir de uma versão
git checkout -b hotfix/v1.0.1 v1.0.0
```

### 5. Exemplo de Release Notes

```markdown
## Release v1.1.0 - "Funcionalidades de Usuário"

### 🆕 Novidades
- Sistema de login completo
- Página de perfil do usuário
- Listagem de vagas disponíveis
- Integração com API backend

### 🔧 Melhorias
- Interface mais intuitiva
- Performance otimizada
- Melhor tratamento de erros

### 🐛 Correções
- Bug na navegação entre telas
- Problema de conectividade em redes lentas
- Correção de layout em dispositivos pequenos

### 📱 Compatibilidade
- Android 5.0+ (API 21+)
- iOS 11.0+
- Flutter 3.6.0+
```

