const apiBase = window.location.pathname.startsWith('/frontend') ? '../api' : '/api';

const money = new Intl.NumberFormat('pt-BR', {
  style: 'currency',
  currency: 'BRL',
});

async function api(path, options = {}) {
  const response = await fetch(`${apiBase}/${path}`, {
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options,
  });
  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    if (response.status === 401) window.location.href = 'login.html';
    throw new Error(data.erro || 'Erro inesperado.');
  }

  return data;
}

function paymentItem(item) {
  return `
    <article class="list-card">
      <div>
        <strong>${item.descricao}</strong>
        <span>Vencimento: ${item.vencimento || 'sem data'}</span>
      </div>
      <div class="right-info">
        <strong>${money.format(Number(item.valor))}</strong>
        <span class="status">${item.status}</span>
      </div>
    </article>
  `;
}

function orderItem(item) {
  return `
    <article class="list-card">
      <div>
        <strong>${item.tipo}</strong>
        <span>${item.mensagem}</span>
      </div>
      <span class="status">${item.status}</span>
    </article>
  `;
}

async function loadDashboard() {
  const [empresaData, pagamentosData, pedidosData] = await Promise.all([
    api('empresas.php'),
    api('pagamentos.php'),
    api('pedidos.php'),
  ]);

  document.querySelector('#companyName').textContent = empresaData.empresa.nome;

  const payments = document.querySelector('#paymentsList');
  payments.innerHTML = pagamentosData.pagamentos.length
    ? pagamentosData.pagamentos.map(paymentItem).join('')
    : '<p class="empty-state">Nenhum pagamento encontrado.</p>';

  const orders = document.querySelector('#ordersList');
  orders.innerHTML = pedidosData.pedidos.length
    ? pedidosData.pedidos.map(orderItem).join('')
    : '<p class="empty-state">Nenhum pedido aberto.</p>';
}

document.querySelector('#logoutBtn').addEventListener('click', async () => {
  await api('logout.php', { method: 'POST' }).catch(() => {});
  window.location.href = 'index.html';
});

document.querySelector('#supportForm').addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = event.currentTarget;
  const message = document.querySelector('#supportMessage');
  message.textContent = 'Enviando...';

  try {
    await api('pedidos.php', {
      method: 'POST',
      body: JSON.stringify(Object.fromEntries(new FormData(form))),
    });
    form.reset();
    message.textContent = 'Pedido enviado com sucesso.';
    await loadDashboard();
  } catch (error) {
    message.textContent = error.message;
  }
});

loadDashboard().catch((error) => {
  document.body.insertAdjacentHTML('beforeend', `<p class="toast">${error.message}</p>`);
});
