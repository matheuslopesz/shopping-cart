# Carrinho de Comprar do Matheus

Esse projeto se trata de um carrinho de comprar, nele você pode:
- Criar um carrinho, já com itens dentro
- Remover itens de um carrinho
- Atualizar os itens de um carrinho
- Existe também uma rotina no sidekiq que fica responsável por destruir carrinhos inativos

## Endpoints
### 1. Registrar um produto no carrinho
Crie um endpoint para adicionar produtos ao carrinho.

Se não houver um carrinho associado à sessão, crie um novo e salve seu ID na sessão.
Adicione o produto ao carrinho, ajustando a quantidade conforme necessário.
Retorne um payload contendo a lista atualizada de produtos no carrinho.

**ROTA:** `POST /cart`

**Payload:**
```json
{
  "product_id": 345,
  "quantity": 2
}
```

**Response:**
```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    },
    {
      "id": 646,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 7.96
}
```

---

### 2. Listar itens do carrinho atual
Listar produtos do carrinho

**ROTA:** `GET /cart`

**Response:**
```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    },
    {
      "id": 646,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 7.96
}
```

---

### 3. Alterar a quantidade de produtos no carrinho
Um carrinho pode ter _N_ produtos, se o produto já existir no carrinho, apenas a quantidade dele deve ser alterada.

**ROTA:** `PATCH /cart/add_item`

**Payload:**
```json
{
  "product_id": 1230,
  "quantity": 1
}
```

**Response:**
```json
{
  "id": 1,
  "products": [
    {
      "id": 1230,
      "name": "Nome do produto X",
      "quantity": 2,
      "unit_price": 7.00,
      "total_price": 14.00
    },
    {
      "id": 1020,
      "name": "Nome do produto Y",
      "quantity": 1,
      "unit_price": 9.90,
      "total_price": 9.90
    }
  ],
  "total_price": 23.90
}
```

---

### 4. Remover um produto do carrinho
Criar um endpoint para excluir um produto do carrinho.

**ROTA:** `DELETE /cart/remove_item?product_id=PRODUCT_ID`

**Response:**
```json
{
  "id": 1,
  "products": [
    {
      "id": 1020,
      "name": "Nome do produto Y",
      "quantity": 1,
      "unit_price": 9.90,
      "total_price": 9.90
    }
  ],
  "total_price": 9.90
}
```
## Como rodar ?
Você precisa ter o docker e o docker-compose instalado, sendo o docker-compose na versão v2.20.3 (talvez funcione em versões um pouco anteriores)

```
./start.sh
```

Para executar os testes, basta entrar em `docker-compose exec web bash` e rodar `bundle exec rspec`.




