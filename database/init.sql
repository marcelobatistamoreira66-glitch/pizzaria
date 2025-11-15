-- Database Schema para Sistema de Pizzaria
-- Criado para uso com PostgreSQL

-- Tabela de Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    telefone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255),
    endereco TEXT,
    numero VARCHAR(10),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(10),
    ponto_referencia TEXT,
    observacoes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Categorias de Produtos
CREATE TABLE IF NOT EXISTS categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    ordem INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Produtos (Pizzas, Bebidas, etc)
CREATE TABLE IF NOT EXISTS produtos (
    id SERIAL PRIMARY KEY,
    categoria_id INTEGER REFERENCES categorias(id),
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco_p DECIMAL(10,2),
    preco_m DECIMAL(10,2),
    preco_g DECIMAL(10,2),
    preco_gg DECIMAL(10,2),
    preco_unitario DECIMAL(10,2),
    tempo_preparo INTEGER DEFAULT 30, -- em minutos
    disponivel BOOLEAN DEFAULT true,
    estoque_atual INTEGER DEFAULT 0,
    estoque_minimo INTEGER DEFAULT 0,
    imagem_url TEXT,
    ingredientes TEXT[],
    alergenos TEXT[],
    vegetariano BOOLEAN DEFAULT false,
    vegano BOOLEAN DEFAULT false,
    sem_gluten BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    numero_pedido VARCHAR(20) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'novo', -- novo, confirmado, preparando, saiu_entrega, entregue, cancelado
    tipo VARCHAR(20) DEFAULT 'delivery', -- delivery, retirada, local
    subtotal DECIMAL(10,2) NOT NULL,
    taxa_entrega DECIMAL(10,2) DEFAULT 0,
    desconto DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(50), -- dinheiro, cartao, pix, online
    troco_para DECIMAL(10,2),
    observacoes TEXT,
    tempo_estimado INTEGER, -- em minutos
    previsao_entrega TIMESTAMP,
    entregue_em TIMESTAMP,
    cancelado_em TIMESTAMP,
    motivo_cancelamento TEXT,
    avaliacao INTEGER, -- 1 a 5
    comentario_avaliacao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Itens do Pedido
CREATE TABLE IF NOT EXISTS pedido_itens (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id INTEGER REFERENCES produtos(id),
    quantidade INTEGER NOT NULL DEFAULT 1,
    tamanho VARCHAR(10), -- P, M, G, GG
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    observacoes TEXT,
    adicionais TEXT[],
    remocoes TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Conversas (Histórico de mensagens)
CREATE TABLE IF NOT EXISTS conversas (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    telefone VARCHAR(20) NOT NULL,
    mensagem TEXT NOT NULL,
    tipo VARCHAR(20) DEFAULT 'recebida', -- recebida, enviada
    contexto JSONB, -- dados do contexto da conversa para IA
    ia_resposta TEXT,
    ia_confianca DECIMAL(3,2), -- 0.00 a 1.00
    transferido_humano BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Estoque (Movimentações)
CREATE TABLE IF NOT EXISTS estoque_movimentacoes (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER REFERENCES produtos(id),
    tipo VARCHAR(20) NOT NULL, -- entrada, saida, ajuste
    quantidade INTEGER NOT NULL,
    quantidade_anterior INTEGER,
    quantidade_atual INTEGER,
    motivo VARCHAR(100),
    observacoes TEXT,
    usuario VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Configurações do Sistema
CREATE TABLE IF NOT EXISTS configuracoes (
    id SERIAL PRIMARY KEY,
    chave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT,
    tipo VARCHAR(50) DEFAULT 'string', -- string, number, boolean, json
    descricao TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Horários de Funcionamento
CREATE TABLE IF NOT EXISTS horarios_funcionamento (
    id SERIAL PRIMARY KEY,
    dia_semana INTEGER NOT NULL, -- 0=domingo, 1=segunda, ..., 6=sábado
    horario_abertura TIME,
    horario_fechamento TIME,
    ativo BOOLEAN DEFAULT true,
    observacoes TEXT
);

-- Índices para melhor performance
CREATE INDEX idx_clientes_telefone ON clientes(telefone);
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_status ON pedidos(status);
CREATE INDEX idx_pedidos_created ON pedidos(created_at);
CREATE INDEX idx_pedido_itens_pedido ON pedido_itens(pedido_id);
CREATE INDEX idx_conversas_telefone ON conversas(telefone);
CREATE INDEX idx_conversas_created ON conversas(created_at);
CREATE INDEX idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX idx_produtos_disponivel ON produtos(disponivel);

-- Inserir dados iniciais
INSERT INTO categorias (nome, descricao, ordem) VALUES
('Pizzas Tradicionais', 'Pizzas com sabores clássicos e tradicionais', 1),
('Pizzas Especiais', 'Pizzas gourmet e especiais da casa', 2),
('Pizzas Doces', 'Pizzas doces para sobremesa', 3),
('Bebidas', 'Refrigerantes, sucos e outras bebidas', 4),
('Adicionais', 'Bordas recheadas e adicionais', 5);

INSERT INTO produtos (categoria_id, nome, descricao, preco_p, preco_m, preco_g, preco_gg, tempo_preparo, vegetariano) VALUES
(1, 'Mussarela', 'Molho de tomate, mussarela e orégano', 25.00, 35.00, 45.00, 55.00, 25, true),
(1, 'Calabresa', 'Molho de tomate, mussarela, calabresa e cebola', 28.00, 38.00, 48.00, 58.00, 25, false),
(1, 'Portuguesa', 'Presunto, mussarela, ovos, cebola, azeitona', 30.00, 42.00, 54.00, 66.00, 30, false),
(1, 'Frango com Catupiry', 'Frango desfiado com catupiry original', 32.00, 44.00, 56.00, 68.00, 30, false),
(2, 'Quatro Queijos', 'Mussarela, provolone, gorgonzola e parmesão', 35.00, 48.00, 62.00, 76.00, 30, true),
(2, 'Margherita', 'Molho de tomate, mussarela de búfala, manjericão e tomate', 38.00, 52.00, 66.00, 80.00, 28, true);

INSERT INTO produtos (categoria_id, nome, descricao, preco_unitario, tempo_preparo) VALUES
(4, 'Coca-Cola 2L', 'Refrigerante Coca-Cola 2 litros', 12.00, 0),
(4, 'Guaraná Antarctica 2L', 'Refrigerante Guaraná 2 litros', 10.00, 0),
(4, 'Suco Natural Laranja 500ml', 'Suco natural de laranja', 8.00, 5);

INSERT INTO configuracoes (chave, valor, tipo, descricao) VALUES
('pizzaria_nome', 'Pizzaria Bella', 'string', 'Nome da pizzaria'),
('taxa_entrega', '5.00', 'number', 'Taxa de entrega padrão'),
('tempo_medio_entrega', '40', 'number', 'Tempo médio de entrega em minutos'),
('pedido_minimo', '30.00', 'number', 'Valor mínimo do pedido'),
('raio_entrega_km', '10', 'number', 'Raio de entrega em km'),
('mensagem_boas_vindas', 'Olá! Bem-vindo à Pizzaria Bella! 🍕', 'string', 'Mensagem de boas vindas do chatbot');

INSERT INTO horarios_funcionamento (dia_semana, horario_abertura, horario_fechamento) VALUES
(0, '18:00', '23:00'), -- Domingo
(1, NULL, NULL), -- Segunda (fechado)
(2, '18:00', '23:00'), -- Terça
(3, '18:00', '23:00'), -- Quarta
(4, '18:00', '23:00'), -- Quinta
(5, '18:00', '23:59'), -- Sexta
(6, '18:00', '23:59'); -- Sábado

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_produtos_updated_at BEFORE UPDATE ON produtos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pedidos_updated_at BEFORE UPDATE ON pedidos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_configuracoes_updated_at BEFORE UPDATE ON configuracoes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
