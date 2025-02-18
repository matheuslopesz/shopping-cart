#!/bin/bash

# Parar e remover containers existentes (se houver)
echo "Parando e removendo containers existentes..."
docker-compose down

# Construir e iniciar os containers
echo "Construindo e iniciando os containers..."
docker-compose up --build -d

# Esperar o banco de dados estar pronto
echo "Aguardando o banco de dados estar pronto..."
while ! docker-compose exec db pg_isready -U postgres -h db; do
  sleep 2
done

# Executar migrações no banco de dados de desenvolvimento
echo "Executando migrações no banco de dados de desenvolvimento..."
docker-compose exec web bin/rails db:migrate

# Executar migrações no banco de dados de teste
echo "Executando migrações no banco de dados de teste..."
docker-compose exec web bin/rails db:migrate RAILS_ENV=test

# Verificar se há migrações pendentes
echo "Verificando migrações pendentes..."
docker-compose exec web bin/rails db:migrate:status

# Iniciar o servidor Rails (se necessário)
echo "Iniciando o servidor Rails..."
docker-compose exec web bin/rails server -b 0.0.0.0

# Mensagem final
echo "Ambiente Docker configurado e pronto para uso!"
echo "Acesse o servidor Rails em: http://localhost:3000"