# 🍕 Sistema de Automação para Pizzaria

Sistema completo de automação para pizzarias com atendimento via WhatsApp, gestão de pedidos, controle de estoque e notificações inteligentes usando **n8n** e **IA**.

## 🚀 Características Principais

### 🤖 Atendimento Inteligente com IA
- Chatbot avançado com GPT-4 para atendimento via WhatsApp
- Respostas naturais e contextualizadas, sem repetições
- Reconhecimento de clientes recorrentes
- Sugestões personalizadas baseadas em histórico
- Verificação automática de horário de funcionamento
- Transferência inteligente para atendente humano quando necessário

### 📦 Gestão Completa de Pedidos
- Criação e rastreamento de pedidos em tempo real
- Cálculo automático de valores, taxas e tempo de entrega
- Notificações automáticas de status para clientes
- Suporte para delivery, retirada e consumo local
- Múltiplas formas de pagamento

### 📊 Controle de Estoque Automatizado
- Monitoramento em tempo real do estoque
- Alertas automáticos para produtos com estoque baixo
- Registro completo de movimentações (entrada/saída/ajuste)
- Baixa automática no estoque ao confirmar pedidos
- Histórico completo de movimentações

### 🔔 Notificações Inteligentes
- Alertas de pedidos sem atualização
- Relatórios diários automáticos com métricas de vendas
- Solicitação automática de avaliação dos clientes
- Dashboard de produtos mais vendidos

## 📋 Pré-requisitos

- Docker e Docker Compose instalados
- Node.js 18+ (opcional, para scripts)
- Conta OpenAI com API Key (para IA)
- WhatsApp Business API ou Evolution API configurado

## ⚙️ Instalação

### 1. Clone o repositório
```bash
git clone <seu-repositorio>
cd pizzaria
```

### 2. Configure as variáveis de ambiente
```bash
cp .env.example .env
```

Edite o arquivo `.env` e configure:
- Credenciais do n8n
- API Key da OpenAI
- Configurações do WhatsApp/Evolution API
- Dados da pizzaria
- Configurações de pagamento

### 3. Inicie os serviços com Docker
```bash
npm start
# ou
docker-compose up -d
```

### 4. Acesse o n8n
```
http://localhost:5678
```

Credenciais padrão (altere no `.env`):
- Usuário: admin
- Senha: [definida no .env]

### 5. Importe os workflows
1. Acesse o n8n no navegador
2. Vá em "Workflows" → "Import from File"
3. Importe cada arquivo da pasta `n8n/workflows/`:
   - `01-atendimento-ia-whatsapp.json`
   - `02-gestao-pedidos.json`
   - `03-controle-estoque.json`
   - `04-notificacoes-inteligentes.json`

### 6. Configure as credenciais no n8n
No n8n, configure as seguintes credenciais:

#### PostgreSQL
- Host: postgres
- Database: pizzaria
- User: pizzaria
- Password: [definida no .env]
- Port: 5432

#### OpenAI API
- API Key: [sua chave da OpenAI]

#### Evolution API (HTTP Header Auth)
- Name: apikey
- Value: [sua API key da Evolution API]

### 7. Ative os workflows
Ative todos os workflows importados no n8n.

## 📖 Uso

### Atendimento via WhatsApp

Os clientes podem interagir com o bot pelo WhatsApp para:
- Consultar o cardápio
- Fazer pedidos
- Acompanhar status de pedidos
- Tirar dúvidas sobre produtos

**Exemplo de conversa:**
```
Cliente: Oi
Bot: Olá! Bem-vindo à Pizzaria Bella 🍕
     Temos pizzas Tradicionais, Especiais e Doces.
     Qual tipo te interessa?

Cliente: Quero uma calabresa grande
Bot: Perfeito! Calabresa G (R$ 48,00) ✅
     Quer adicionar algo mais?

Cliente: Uma coca 2L
Bot: Anotado! Coca-Cola 2L (R$ 12,00) ✅

     Seu pedido:
     • Calabresa G - R$ 48,00
     • Coca-Cola 2L - R$ 12,00
     Subtotal: R$ 60,00

     É para delivery ou retirada?
```

### Criar Pedido via API

```bash
curl -X POST http://localhost:5678/webhook/criar-pedido \
  -H "Content-Type: application/json" \
  -d '{
    "cliente_id": 1,
    "tipo": "delivery",
    "itens": [
      {
        "produto_id": 2,
        "quantidade": 1,
        "tamanho": "G",
        "preco_unitario": 48.00
      }
    ],
    "forma_pagamento": "dinheiro",
    "troco_para": 100.00,
    "observacoes": "Sem cebola"
  }'
```

### Atualizar Status do Pedido

```bash
curl -X POST http://localhost:5678/webhook/atualizar-status-pedido \
  -H "Content-Type: application/json" \
  -d '{
    "numero_pedido": "PED20241115-001",
    "novo_status": "preparando"
  }'
```

**Status disponíveis:**
- `novo` - Pedido recebido
- `confirmado` - Pedido confirmado
- `preparando` - Em preparo
- `saiu_entrega` - Saiu para entrega
- `entregue` - Pedido entregue
- `cancelado` - Pedido cancelado

### Atualizar Estoque

```bash
curl -X POST http://localhost:5678/webhook/atualizar-estoque \
  -H "Content-Type: application/json" \
  -d '{
    "produto_id": 1,
    "tipo": "entrada",
    "quantidade": 50,
    "motivo": "Compra de ingredientes",
    "usuario": "admin"
  }'
```

**Tipos de movimentação:**
- `entrada` - Adiciona ao estoque
- `saida` - Remove do estoque
- `ajuste` - Define quantidade absoluta

## 🏗️ Arquitetura

```
┌─────────────────┐
│   WhatsApp      │
│   (Cliente)     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│         Evolution API                    │
│    (WhatsApp Business API)              │
└────────┬────────────────────────────────┘
         │ Webhook
         ▼
┌─────────────────────────────────────────┐
│              n8n                         │
│  ┌─────────────────────────────────┐   │
│  │ Workflow: Atendimento IA        │   │
│  │  - Identifica cliente           │   │
│  │  - Busca contexto/histórico     │   │
│  │  - Consulta cardápio            │   │
│  │  - Processa com OpenAI          │   │
│  │  - Envia resposta               │   │
│  └─────────────────────────────────┘   │
│                                          │
│  ┌─────────────────────────────────┐   │
│  │ Workflow: Gestão de Pedidos     │   │
│  │  - Cria pedidos                 │   │
│  │  - Atualiza status              │   │
│  │  - Envia notificações           │   │
│  └─────────────────────────────────┘   │
│                                          │
│  ┌─────────────────────────────────┐   │
│  │ Workflow: Controle Estoque      │   │
│  │  - Monitora estoque             │   │
│  │  - Alerta estoque baixo         │   │
│  │  - Registra movimentações       │   │
│  └─────────────────────────────────┘   │
│                                          │
│  ┌─────────────────────────────────┐   │
│  │ Workflow: Notificações          │   │
│  │  - Relatórios diários           │   │
│  │  - Alertas de pedidos           │   │
│  │  - Solicitação de avaliação     │   │
│  └─────────────────────────────────┘   │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│         PostgreSQL Database              │
│  - Clientes                              │
│  - Produtos / Categorias                 │
│  - Pedidos / Itens                       │
│  - Conversas (histórico)                 │
│  - Estoque / Movimentações               │
│  - Configurações                         │
└──────────────────────────────────────────┘
```

## 📁 Estrutura do Projeto

```
pizzaria/
├── n8n/
│   ├── workflows/              # Workflows n8n (JSON)
│   │   ├── 01-atendimento-ia-whatsapp.json
│   │   ├── 02-gestao-pedidos.json
│   │   ├── 03-controle-estoque.json
│   │   └── 04-notificacoes-inteligentes.json
│   └── credentials/            # Credenciais (não versionado)
├── database/
│   └── init.sql               # Schema do banco de dados
├── src/
│   ├── config/
│   │   └── ai-prompts.json    # Sistema de prompts da IA
│   ├── api/                   # APIs auxiliares (futuro)
│   └── utils/                 # Utilitários (futuro)
├── docs/                      # Documentação adicional
├── scripts/                   # Scripts de automação
├── .env.example               # Exemplo de variáveis de ambiente
├── docker-compose.yml         # Configuração Docker
├── package.json               # Dependências Node.js
└── README.md                  # Este arquivo
```

## 🎯 Funcionalidades da IA

### Anti-Repetição Inteligente
O sistema de IA foi desenvolvido com engenharia de prompt avançada para:
- Nunca repetir a mesma frase de confirmação seguida
- Variar o vocabulário e estrutura das respostas
- Manter contexto da conversa sem re-perguntar informações já fornecidas
- Adaptar o tom de acordo com o cliente e situação

### Contexto Rico
A IA tem acesso a:
- Histórico completo de pedidos do cliente
- Últimas 10 mensagens da conversa
- Cardápio completo com preços e disponibilidade
- Horário de funcionamento em tempo real
- Configurações da pizzaria

### Sugestões Inteligentes
- Produtos complementares (ex: bebida com pizza)
- Baseadas em histórico do cliente
- Produtos mais vendidos
- Nunca insistente ou repetitiva

## 🔐 Segurança

- Todas as credenciais em variáveis de ambiente
- Arquivo `.gitignore` configurado para não versionar dados sensíveis
- Autenticação básica no n8n
- Validação de dados em todos os webhooks
- Prepared statements para prevenir SQL injection

## 📊 Monitoramento

### Logs
```bash
# Ver logs de todos os serviços
npm run logs

# Ver apenas logs do n8n
npm run logs:n8n

# Ver logs do PostgreSQL
docker-compose logs -f postgres
```

### Métricas Diárias
O sistema envia automaticamente às 9h um relatório com:
- Total de pedidos do dia anterior
- Faturamento total
- Ticket médio
- Taxa de cancelamento
- Top 5 produtos mais vendidos

## 🛠️ Manutenção

### Backup do Banco de Dados
```bash
docker-compose exec postgres pg_dump -U pizzaria pizzaria > backup_$(date +%Y%m%d).sql
```

### Restaurar Backup
```bash
docker-compose exec -T postgres psql -U pizzaria pizzaria < backup_20241115.sql
```

### Atualizar Workflows
1. Faça as alterações no n8n
2. Exporte o workflow (Settings → Download)
3. Salve na pasta `n8n/workflows/`
4. Commit no git

## 🐛 Troubleshooting

### IA não está respondendo
1. Verifique se a API Key da OpenAI está correta no `.env`
2. Verifique os logs: `docker-compose logs -f n8n`
3. Certifique-se de que o workflow está ativo

### WhatsApp não está recebendo mensagens
1. Verifique a configuração da Evolution API
2. Teste o webhook manualmente com curl
3. Verifique se o instance_name está correto

### Banco de dados não inicializa
1. Certifique-se de que as portas não estão em uso
2. Verifique os logs: `docker-compose logs -f postgres`
3. Recrie os volumes: `docker-compose down -v && docker-compose up -d`

## 📝 Comandos Úteis

```bash
# Iniciar sistema
npm start

# Parar sistema
npm stop

# Reiniciar sistema
npm restart

# Ver logs
npm run logs

# Modo desenvolvimento (logs em tempo real)
npm run dev
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT.

## 💬 Suporte

Para dúvidas ou problemas:
- Abra uma issue no GitHub
- Entre em contato: marcelobatistamoreira66@gmail.com

---

**Desenvolvido com ❤️ para pizzarias que querem automatizar e escalar seus negócios**