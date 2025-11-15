# 📚 Documentação dos Workflows

Esta documentação detalha cada workflow do sistema de automação da pizzaria.

## Índice
1. [Workflow 01: Atendimento IA via WhatsApp](#workflow-01-atendimento-ia-whatsapp)
2. [Workflow 02: Gestão de Pedidos](#workflow-02-gestão-de-pedidos)
3. [Workflow 03: Controle de Estoque](#workflow-03-controle-de-estoque)
4. [Workflow 04: Notificações Inteligentes](#workflow-04-notificações-inteligentes)

---

## Workflow 01: Atendimento IA WhatsApp

**Arquivo:** `n8n/workflows/01-atendimento-ia-whatsapp.json`

### Objetivo
Processar mensagens recebidas via WhatsApp e responder automaticamente usando IA (GPT-4), mantendo contexto da conversa e oferecendo atendimento natural e eficiente.

### Fluxo de Execução

```
Webhook ← Mensagem WhatsApp
    ↓
Filtrar apenas mensagens de texto
    ↓
Buscar/Criar cliente no banco
    ↓
[Paralelo] Buscar dados contextuais:
    → Histórico de pedidos do cliente
    → Cardápio completo
    → Configurações da pizzaria
    → Horários de funcionamento
    ↓
Montar contexto completo
    ↓
Buscar últimas 10 mensagens da conversa
    ↓
Montar prompt otimizado para IA
    ↓
Enviar para OpenAI (GPT-4)
    ↓
Processar resposta e extrair intenções
    ↓
Salvar conversa no histórico
    ↓
Enviar resposta via WhatsApp
    ↓
Retornar sucesso ao webhook
```

### Webhook de Entrada
- **URL:** `http://localhost:5678/webhook/webhook-whatsapp`
- **Método:** POST
- **Formato esperado:**
```json
{
  "from": "5511999999999",
  "pushName": "João Silva",
  "body": "Oi, quero pedir uma pizza",
  "type": "message"
}
```

### Características do Prompt de IA

#### Anti-Repetição
- Sistema de variação de respostas
- Nunca usa a mesma confirmação duas vezes seguidas
- Adapta tom baseado no contexto

#### Contexto Rico
- Histórico de pedidos do cliente
- Produtos disponíveis em tempo real
- Horário de funcionamento
- Configurações personalizadas

#### Inteligência de Roteamento
- Detecta quando transferir para humano
- Níveis de confiança nas respostas
- Escalação automática em casos complexos

### Pontos de Atenção
⚠️ O prompt de IA está em `src/config/ai-prompts.json` - edite lá para personalizar
⚠️ Temperatura configurada em 0.7 para respostas naturais mas consistentes
⚠️ Max tokens: 500 para evitar respostas muito longas

---

## Workflow 02: Gestão de Pedidos

**Arquivo:** `n8n/workflows/02-gestao-pedidos.json`

### Objetivo
Gerenciar criação e atualização de pedidos, incluindo cálculo de valores, confirmações e notificações.

### Fluxo 1: Criar Pedido

```
Webhook ← Dados do pedido
    ↓
Validar e processar dados
    → Gerar número único do pedido
    → Calcular subtotal
    → Aplicar taxa de entrega
    → Aplicar descontos
    → Calcular tempo estimado
    ↓
Inserir pedido no banco
    ↓
Inserir itens do pedido
    ↓
Buscar pedido completo com detalhes
    ↓
Formatar mensagem de confirmação
    ↓
Enviar WhatsApp para cliente
    ↓
Retornar dados do pedido
```

### Webhook: Criar Pedido
- **URL:** `http://localhost:5678/webhook/criar-pedido`
- **Método:** POST
- **Exemplo:**
```json
{
  "cliente_id": 1,
  "tipo": "delivery",
  "itens": [
    {
      "produto_id": 2,
      "quantidade": 1,
      "tamanho": "G",
      "preco_unitario": 48.00,
      "observacoes": "Sem cebola"
    }
  ],
  "forma_pagamento": "dinheiro",
  "troco_para": 100.00,
  "taxa_entrega": 5.00,
  "desconto": 0.00
}
```

### Fluxo 2: Atualizar Status

```
Webhook ← Novo status
    ↓
Atualizar status no banco
    ↓
Buscar dados do cliente
    ↓
Formatar mensagem baseada no status
    ↓
Enviar notificação WhatsApp
    ↓
Retornar confirmação
```

### Webhook: Atualizar Status
- **URL:** `http://localhost:5678/webhook/atualizar-status-pedido`
- **Método:** POST
- **Exemplo:**
```json
{
  "numero_pedido": "PED20241115-001",
  "novo_status": "preparando",
  "motivo_cancelamento": "Cliente solicitou" // apenas se cancelado
}
```

### Status Disponíveis
- `novo` - Pedido acabou de ser criado
- `confirmado` - Pedido confirmado pela pizzaria
- `preparando` - Pizza está sendo preparada
- `saiu_entrega` - Saiu para entrega
- `entregue` - Pedido foi entregue
- `cancelado` - Pedido cancelado

### Mensagens Automáticas por Status
Cada mudança de status gera mensagem personalizada:
- **confirmado**: "Pedido confirmado! Tempo estimado: X minutos"
- **preparando**: "Seu pedido está sendo preparado!"
- **saiu_entrega**: "Saiu para entrega! Chega em breve"
- **entregue**: "Pedido entregue! Avalie seu pedido"
- **cancelado**: "Pedido cancelado. Motivo: X"

---

## Workflow 03: Controle de Estoque

**Arquivo:** `n8n/workflows/03-controle-estoque.json`

### Objetivo
Monitorar e gerenciar estoque de produtos automaticamente.

### Fluxo 1: Verificação Periódica

```
Trigger (a cada 4 horas)
    ↓
Buscar produtos com estoque <= estoque_minimo
    ↓
Tem produtos baixos?
    ↓ Sim
Formatar alerta
    ↓
Enviar WhatsApp para gestor
```

### Fluxo 2: Atualização Manual

```
Webhook ← Movimentação
    ↓
Buscar estoque atual
    ↓
Calcular novo estoque
    → entrada: estoque + quantidade
    → saida: estoque - quantidade
    → ajuste: quantidade (valor absoluto)
    ↓
Atualizar produto
    ↓
Registrar movimentação
    ↓
Retornar confirmação
```

### Webhook: Atualizar Estoque
- **URL:** `http://localhost:5678/webhook/atualizar-estoque`
- **Método:** POST
- **Exemplo:**
```json
{
  "produto_id": 1,
  "tipo": "entrada",
  "quantidade": 50,
  "motivo": "Compra de ingredientes",
  "observacoes": "Fornecedor X",
  "usuario": "admin"
}
```

### Fluxo 3: Baixa Automática por Pedido

```
Webhook ← ID do pedido
    ↓
Buscar todos os itens do pedido
    ↓
Para cada item:
    ↓
    Dar baixa no estoque
    ↓
    Registrar movimentação
    ↓
Retornar resumo
```

### Webhook: Baixa por Pedido
- **URL:** `http://localhost:5678/webhook/baixa-estoque-pedido`
- **Método:** POST
- **Exemplo:**
```json
{
  "pedido_id": 123
}
```

### Tipos de Movimentação
- **entrada**: Adiciona produtos ao estoque
- **saida**: Remove produtos do estoque
- **ajuste**: Define quantidade absoluta (inventário)

---

## Workflow 04: Notificações Inteligentes

**Arquivo:** `n8n/workflows/04-notificacoes-inteligentes.json`

### Objetivo
Automatizar notificações proativas para melhorar gestão e relacionamento com clientes.

### Fluxo 1: Alerta de Pedidos Parados

**Trigger:** A cada 10 minutos

```
Buscar pedidos sem atualização há > 30 min
    ↓
Tem pedidos parados?
    ↓ Sim
Formatar alerta
    ↓
Enviar WhatsApp para gestor
```

**Exemplo de Alerta:**
```
⚠️ ALERTA - PEDIDOS SEM ATUALIZAÇÃO

2 pedido(s) há mais de 30 minutos sem atualização:

1. Pedido: PED20241115-001
   Cliente: João Silva
   Status: preparando
   ⏱️ Sem atualização há: 45 minutos

2. Pedido: PED20241115-002
   Cliente: Maria Souza
   Status: confirmado
   ⏱️ Sem atualização há: 35 minutos

🔔 Verifique esses pedidos!
```

### Fluxo 2: Relatório Diário

**Trigger:** Diariamente às 9h

```
[Paralelo]
    → Calcular métricas do dia anterior
    → Buscar top 5 produtos mais vendidos
    ↓
Formatar relatório completo
    ↓
Enviar WhatsApp para gestor
```

**Exemplo de Relatório:**
```
📊 RELATÓRIO DIÁRIO - 14/11/2024

📈 RESUMO GERAL
Total de Pedidos: 45
✅ Entregues: 42
❌ Cancelados: 1
⏳ Em Andamento: 2

💰 FINANCEIRO
Faturamento: R$ 2.450,00
Ticket Médio: R$ 58,33

🏆 TOP 5 PRODUTOS
1. Calabresa - 18 vendas (R$ 864,00)
2. Portuguesa - 12 vendas (R$ 648,00)
3. Frango Catupiry - 10 vendas (R$ 560,00)
4. Mussarela - 8 vendas (R$ 280,00)
5. Quatro Queijos - 6 vendas (R$ 372,00)
```

### Fluxo 3: Solicitação de Avaliação

**Trigger:** Diariamente às 20h

```
Buscar pedidos entregues hoje sem avaliação
    ↓
Tem pedidos para avaliar?
    ↓ Sim
Para cada pedido:
    ↓
    Formatar mensagem de avaliação
    ↓
    Enviar WhatsApp para cliente
```

**Exemplo de Mensagem:**
```
Olá João! 😊

Esperamos que tenha gostado da sua pizza! 🍕

Pedido: PED20241115-001

Por favor, avalie nosso atendimento:

⭐⭐⭐⭐⭐ Excelente
⭐⭐⭐⭐ Bom
⭐⭐⭐ Regular
⭐⭐ Ruim
⭐ Muito Ruim

Sua opinião é muito importante para nós!
```

---

## Melhores Práticas

### 1. Monitoramento
- Verifique os logs regularmente: `npm run logs:n8n`
- Configure alertas de erro no n8n
- Monitore taxa de sucesso dos workflows

### 2. Testes
Antes de ativar em produção:
```bash
# Teste cada webhook manualmente
curl -X POST http://localhost:5678/webhook/criar-pedido \
  -H "Content-Type: application/json" \
  -d @test-data/pedido.json
```

### 3. Backup
- Exporte workflows semanalmente
- Backup do banco diariamente
- Versione workflows no git

### 4. Segurança
- Use HTTPS em produção
- Valide todos os inputs
- Não exponha credenciais nos logs
- Rate limiting nos webhooks

### 5. Performance
- Índices no banco para queries frequentes
- Cache de cardápio (Redis)
- Limitar histórico de mensagens
- Monitorar tempo de resposta da IA

---

## Troubleshooting Comum

### Workflow não executa
1. Verifique se está ativo
2. Teste o trigger manualmente
3. Verifique credenciais

### Erro na IA
1. Verifique API Key da OpenAI
2. Verifique rate limits
3. Verifique formato do prompt

### Webhook não responde
1. Teste URL diretamente
2. Verifique logs de erro
3. Verifique timeout

### Banco de dados lento
1. Analise queries lentas
2. Adicione índices necessários
3. Otimize joins complexos

---

## Personalizações Comuns

### Alterar prompts da IA
Edite: `src/config/ai-prompts.json`

### Adicionar novo status de pedido
1. Adicione no enum do banco
2. Adicione mensagem em `02-gestao-pedidos.json`
3. Atualize documentação

### Alterar horários de notificações
Edite o cron expression nos triggers:
- `*/10 * * * *` = A cada 10 minutos
- `0 9 * * *` = Diariamente às 9h
- `0 */4 * * *` = A cada 4 horas

### Adicionar novos tipos de alerta
Clone o workflow 04 e customize os triggers e queries

---

**Documentação atualizada em:** 15/11/2024
