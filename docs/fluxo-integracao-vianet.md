# Fluxo de integracao Vianet Minas

## Papel de cada banco

`u308598921_conecta_play`

- Guarda empresas SaaS, dominios, conteudos, parceiros e beneficios.
- Guarda sessoes de clientes sincronizados.
- Guarda logs de acesso, paginas visitadas e eventos de engajamento.
- Guarda dados cacheados para a experiencia do ConectaPlay.

`u308598921_via_ccm`

- Continua sendo a fonte operacional da Vianet Minas.
- Guarda os clientes reais da empresa.
- Deve ser consultado para localizar o assinante por CPF/CNPJ.
- Pode ser usado depois para consultar contratos, boletos, Pix e status financeiro.

## Fluxo do cliente

1. Cliente acessa `play.vianetminas.com.br`.
2. A home abre sem login, com conteudos, trailers, canal ao vivo e beneficios publicos.
3. Ao clicar em pagamentos, minha internet, suporte ou cupom exclusivo, o cliente informa CPF/CNPJ.
4. O ConectaPlay consulta o banco `u308598921_via_ccm`.
5. Se encontrar o cliente, sincroniza um cadastro minimo em `clientes_app`.
6. A sessao fica vinculada ao cliente sincronizado.
7. O ConectaPlay registra login, paginas visitadas e uso dos recursos em `acessos_clientes`.

## Proxima etapa

Estrutura real mapeada no dump `u308598921_via_ccm.sql`:

- empresa Vianet: `empresas.id = 2`;
- clientes: `clientes`;
- CPF do cliente: `clientes.cpf`;
- nome: `clientes.nome`;
- email: `clientes.email`;
- telefone/WhatsApp: `clientes.contato_whatsapp`;
- login atual da area do cliente: `clientes.usuario_area_cliente` e `clientes.senha_area_cliente`;
- contratos: `contratos`;
- planos: `planos`;
- contas em aberto: `recebimentos`;
- status financeiros abertos: `aberto`, `gerado`, `parcial`, `vencido`.

## Financeiro no MVP

No MVP, a tela de pagamentos consulta `recebimentos` diretamente e mostra:

- referencia;
- valor em aberto;
- vencimento;
- status;
- numero do contrato;
- competencia.

Pix e boleto entram na etapa seguinte, quando mapeamos onde o CCM guarda ou gera:

- link de boleto;
- linha digitavel;
- copia e cola Pix;
- id da cobranca no gateway.
