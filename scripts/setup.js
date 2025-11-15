#!/usr/bin/env node

/**
 * Script de setup inicial do sistema de pizzaria
 * Verifica dependências e configura ambiente
 */

const fs = require('fs');
const path = require('path');

console.log('🍕 Setup do Sistema de Automação para Pizzaria\n');

// Verificar se .env existe
const envPath = path.join(__dirname, '..', '.env');
const envExamplePath = path.join(__dirname, '..', '.env.example');

if (!fs.existsSync(envPath)) {
  console.log('⚠️  Arquivo .env não encontrado!');
  console.log('📋 Copiando .env.example para .env...\n');

  try {
    fs.copyFileSync(envExamplePath, envPath);
    console.log('✅ Arquivo .env criado com sucesso!');
    console.log('⚠️  IMPORTANTE: Edite o arquivo .env e configure as variáveis necessárias:\n');
    console.log('   - OPENAI_API_KEY');
    console.log('   - EVOLUTION_API_KEY');
    console.log('   - N8N_BASIC_AUTH_PASSWORD');
    console.log('   - Outras configurações da pizzaria\n');
  } catch (error) {
    console.error('❌ Erro ao criar .env:', error.message);
    process.exit(1);
  }
} else {
  console.log('✅ Arquivo .env encontrado\n');
}

// Verificar estrutura de pastas
const requiredDirs = [
  'n8n/workflows',
  'n8n/credentials',
  'database',
  'src/config',
  'src/api',
  'src/utils',
  'scripts',
  'docs/workflows',
  'docs/api',
  'docs/setup',
  'logs',
  'backups'
];

console.log('📁 Verificando estrutura de pastas...\n');

requiredDirs.forEach(dir => {
  const dirPath = path.join(__dirname, '..', dir);
  if (!fs.existsSync(dirPath)) {
    console.log(`   Criando ${dir}...`);
    fs.mkdirSync(dirPath, { recursive: true });
  } else {
    console.log(`   ✓ ${dir}`);
  }
});

console.log('\n✅ Estrutura de pastas OK\n');

// Verificar arquivos essenciais
const requiredFiles = [
  'docker-compose.yml',
  'package.json',
  '.gitignore',
  'database/init.sql',
  'src/config/ai-prompts.json',
  'n8n/workflows/01-atendimento-ia-whatsapp.json',
  'n8n/workflows/02-gestao-pedidos.json',
  'n8n/workflows/03-controle-estoque.json',
  'n8n/workflows/04-notificacoes-inteligentes.json'
];

console.log('📄 Verificando arquivos essenciais...\n');

let missingFiles = [];

requiredFiles.forEach(file => {
  const filePath = path.join(__dirname, '..', file);
  if (fs.existsSync(filePath)) {
    console.log(`   ✓ ${file}`);
  } else {
    console.log(`   ✗ ${file} (faltando)`);
    missingFiles.push(file);
  }
});

if (missingFiles.length > 0) {
  console.log('\n⚠️  Alguns arquivos essenciais estão faltando.');
  console.log('   Execute o setup completo do projeto primeiro.\n');
} else {
  console.log('\n✅ Todos os arquivos essenciais presentes\n');
}

// Verificar Docker
console.log('🐳 Verificando Docker...\n');

const { execSync } = require('child_process');

try {
  execSync('docker --version', { stdio: 'pipe' });
  console.log('   ✓ Docker instalado');

  try {
    execSync('docker-compose --version', { stdio: 'pipe' });
    console.log('   ✓ Docker Compose instalado\n');
  } catch {
    console.log('   ✗ Docker Compose não encontrado\n');
    console.log('   Instale o Docker Compose: https://docs.docker.com/compose/install/\n');
  }
} catch {
  console.log('   ✗ Docker não encontrado\n');
  console.log('   Instale o Docker: https://docs.docker.com/get-docker/\n');
}

// Resumo final
console.log('━'.repeat(60));
console.log('📋 RESUMO DO SETUP\n');

if (!fs.existsSync(envPath)) {
  console.log('⚠️  Configure o arquivo .env antes de continuar');
} else {
  console.log('✅ Ambiente configurado');
}

if (missingFiles.length > 0) {
  console.log('⚠️  Alguns arquivos essenciais estão faltando');
} else {
  console.log('✅ Todos os arquivos presentes');
}

console.log('\n📚 PRÓXIMOS PASSOS:\n');
console.log('1. Edite o arquivo .env com suas configurações');
console.log('2. Inicie os serviços: npm start');
console.log('3. Acesse o n8n: http://localhost:5678');
console.log('4. Importe os workflows da pasta n8n/workflows/');
console.log('5. Configure as credenciais no n8n');
console.log('6. Ative todos os workflows\n');
console.log('📖 Documentação completa: README.md\n');
console.log('━'.repeat(60));
