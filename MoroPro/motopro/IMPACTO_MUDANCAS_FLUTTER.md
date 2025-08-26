# 📱 Impacto das Mudanças no App Flutter - Remoção do Campo `nome`

## 🎯 Resumo do Impacto

**SIM, as mudanças no campo `nome` do Motoboy implicam em mudanças significativas no app Flutter.** O app atual usa o campo `nome` em várias partes e precisará ser atualizado para usar `user.full_name`.

## 📊 Análise do Código Flutter Atual

### 🔍 Arquivos que usam o campo `nome`:

#### 1. **Services** (APIs)
- ✅ `pre_cadastro_service.dart` - Envia `nome` para API
- ✅ `login_user_service.dart` - Recebe `nome` da API
- ✅ `local_storage.dart` - Salva `nome` localmente

#### 2. **Providers** (Estado)
- ✅ `user_provider.dart` - Gerencia `nome` do usuário

#### 3. **Pages** (Interface)
- ✅ `pre_cadastro_page.dart` - Campo de entrada `nome`
- ✅ `perfil_page.dart` - Exibe `nome` do usuário
- ✅ `home_page.dart` - Pode usar `nome` em menus

## 🚨 Problemas Identificados

### ❌ **Problema 1: API de Pré-cadastro**
```dart
// pre_cadastro_service.dart - LINHA 25
body: jsonEncode({
  'nome': nome,  // ❌ Campo que será removido
  'cpf': cpf,
  'email': email,
  // ...
}),
```

### ❌ **Problema 2: API de Login**
```dart
// login_user_service.dart - LINHA 35
nome: response.data['nome'] ?? '',  // ❌ Campo que será removido
```

### ❌ **Problema 3: Armazenamento Local**
```dart
// local_storage.dart - Provavelmente salva 'nome'
await LocalStorage.saveMotoboyData(
  loginResult.motoboyId,
  loginResult.nome,  // ❌ Campo que será removido
  // ...
);
```

### ❌ **Problema 4: Provider de Usuário**
```dart
// user_provider.dart - LINHA 5
String? _nome;  // ❌ Campo que será removido
String? get nome => _nome;  // ❌ Getter que será removido
```

## 🔧 Mudanças Necessárias no Flutter

### **1. Atualizar API de Pré-cadastro**

**Antes:**
```dart
body: jsonEncode({
  'nome': nome,
  'cpf': cpf,
  'email': email,
  // ...
}),
```

**Depois:**
```dart
body: jsonEncode({
  'full_name': nome,  // ✅ Usar full_name em vez de nome
  'cpf': cpf,
  'email': email,
  // ...
}),
```

### **2. Atualizar API de Login**

**Antes:**
```dart
nome: response.data['nome'] ?? '',
```

**Depois:**
```dart
nome: response.data['nome'] ?? '',  // ✅ API continuará retornando 'nome' (será user.full_name)
// OU
nome: response.data['user']?['full_name'] ?? '',  // ✅ Se API mudar estrutura
```

### **3. Atualizar Armazenamento Local**

**Antes:**
```dart
await LocalStorage.saveMotoboyData(
  loginResult.motoboyId,
  loginResult.nome,
  // ...
);
```

**Depois:**
```dart
await LocalStorage.saveMotoboyData(
  loginResult.motoboyId,
  loginResult.nome,  // ✅ Continuará funcionando (será user.full_name)
  // ...
);
```

### **4. Atualizar Provider (se necessário)**

**Antes:**
```dart
String? _nome;
String? get nome => _nome;
```

**Depois:**
```dart
String? _nome;  // ✅ Pode manter o nome da variável
String? get nome => _nome;  // ✅ Pode manter o getter
// OU
String? _fullName;  // ✅ Se quiser ser mais explícito
String? get fullName => _fullName;
```

## 📋 Checklist de Mudanças no Flutter

### ✅ **Fase 1: Atualizar Services**
- [ ] `pre_cadastro_service.dart` - Mudar `nome` para `full_name`
- [ ] `login_user_service.dart` - Verificar se API retorna `nome` corretamente
- [ ] `local_storage.dart` - Verificar se salva dados corretamente

### ✅ **Fase 2: Atualizar Providers**
- [ ] `user_provider.dart` - Verificar se precisa de mudanças
- [ ] Outros providers que usem `nome`

### ✅ **Fase 3: Atualizar Pages**
- [ ] `pre_cadastro_page.dart` - Verificar se campo funciona
- [ ] `perfil_page.dart` - Verificar se exibe nome corretamente
- [ ] `home_page.dart` - Verificar se usa nome corretamente

### ✅ **Fase 4: Testes**
- [ ] Testar pré-cadastro
- [ ] Testar login
- [ ] Testar exibição de nome no perfil
- [ ] Testar armazenamento local

## 🎯 Estratégia de Implementação

### **Opção 1: Mudança Gradual (Recomendada)**
1. **Backend primeiro**: Remover campo `nome` do Django
2. **API adaptada**: Django retorna `user.full_name` como `nome` na API
3. **Flutter sem mudanças**: App continua funcionando normalmente
4. **Flutter depois**: Atualizar para usar `full_name` explicitamente

### **Opção 2: Mudança Simultânea**
1. **Backend e Flutter juntos**: Fazer todas as mudanças de uma vez
2. **Mais arriscado**: Pode quebrar funcionalidades
3. **Testes extensivos**: Necessário

## 🚀 Plano de Implementação Recomendado

### **Fase 1: Preparação Backend**
1. ✅ Resolver conflitos de dados (CONCLUÍDO)
2. 🔄 Atualizar código Django para usar `user.full_name`
3. 📝 Criar migração Django
4. 🧪 Testar APIs

### **Fase 2: Adaptação da API**
1. 🔄 Modificar serializers para retornar `user.full_name` como `nome`
2. 🧪 Testar se APIs continuam funcionando
3. 📋 Documentar mudanças

### **Fase 3: Atualização Flutter**
1. 🔄 Atualizar `pre_cadastro_service.dart`
2. 🔄 Verificar `login_user_service.dart`
3. 🔄 Testar todas as funcionalidades
4. 🧪 Testes de integração

### **Fase 4: Deploy e Monitoramento**
1. 🚀 Deploy do backend
2. 🚀 Deploy do Flutter
3. 📊 Monitorar logs e erros
4. 🔧 Corrigir problemas se necessário

## ⚠️ Riscos e Mitigações

### 🚨 **Riscos Identificados:**
1. **Breaking changes**: App pode parar de funcionar
2. **Dados perdidos**: Informações de nome podem ser perdidas
3. **Inconsistência**: Dados diferentes entre backend e frontend

### 🛡️ **Mitigações:**
1. **Backup completo**: Antes de qualquer mudança
2. **Testes extensivos**: Em ambiente de desenvolvimento
3. **Rollback plan**: Plano para reverter mudanças
4. **Deploy gradual**: Backend primeiro, depois Flutter

## 📊 Benefícios Esperados

### ✅ **Após as Mudanças:**
1. **Consistência**: Dados sempre sincronizados
2. **Simplicidade**: Menos código para manter
3. **Padrão Django**: Usa campos padrão do framework
4. **Menos bugs**: Elimina conflitos de dados

## 🎯 Conclusão

**As mudanças no campo `nome` do Motoboy DEFINITIVAMENTE impactam o app Flutter.** O app atual usa o campo `nome` em várias partes e precisará ser atualizado.

**Recomendação**: Implementar a **Opção 1 (Mudança Gradual)** para minimizar riscos e garantir que o app continue funcionando durante a transição.

---

**Status**: 📋 Análise Concluída  
**Impacto**: 🔴 ALTO - Mudanças necessárias no Flutter  
**Estratégia**: 🟡 Mudança Gradual Recomendada  
**Responsável**: Equipe de Desenvolvimento  
**Data**: Agosto 2025
