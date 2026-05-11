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
  const boleto = item.link_boleto
    ? `<a class="mini-action" href="${item.link_boleto}" target="_blank" rel="noopener">Boleto</a>`
    : '';
  const pix = item.codigo_pix
    ? `<button class="mini-action" type="button" data-copy-pix="${encodeURIComponent(item.codigo_pix)}">Pix</button>`
    : '';

  return `
    <article class="list-card">
      <div>
        <strong>${item.descricao}</strong>
        <span>Vencimento: ${item.vencimento || 'sem data'}</span>
      </div>
      <div class="right-info">
        <strong>${money.format(Number(item.valor))}</strong>
        <span class="status">${item.status}</span>
        <div class="inline-actions">${boleto}${pix}</div>
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

function internetPanel(data) {
  const internet = data.internet || {};
  const cliente = data.cliente || {};
  const download = internet.velocidade_download || '-';
  const upload = internet.velocidade_upload || '-';
  const vencimento = internet.vencimento_dia ? `Todo dia ${internet.vencimento_dia}` : 'Nao informado';
  const whatsapp = internet.suporte_whatsapp
    ? `<a class="ghost-btn" href="https://wa.me/${internet.suporte_whatsapp}" target="_blank" rel="noopener">WhatsApp</a>`
    : '<a class="ghost-btn" href="#suporte">Abrir suporte</a>';

  return `
    <article class="internet-card">
      <div>
        <span class="eyebrow">Contrato</span>
        <h3>${internet.plano || 'Plano nao informado'}</h3>
        <p>${cliente.nome || 'Cliente'}${internet.endereco_instalacao ? ` - ${internet.endereco_instalacao}` : ''}</p>
      </div>
      <div class="speed-grid">
        <div>
          <span>Download</span>
          <strong>${download}</strong>
        </div>
        <div>
          <span>Upload</span>
          <strong>${upload}</strong>
        </div>
        <div>
          <span>Vencimento</span>
          <strong>${vencimento}</strong>
        </div>
        <div>
          <span>Status</span>
          <strong>${internet.status || 'sem_contrato'}</strong>
        </div>
      </div>
      <div class="hero-actions">
        <a class="primary-btn" href="#pagamentos">Pagar agora</a>
        ${whatsapp}
      </div>
    </article>
  `;
}

async function loadDashboard() {
  const [empresaData, internetData, pagamentosData, pedidosData] = await Promise.all([
    api('empresas.php'),
    api('minha-internet.php'),
    api('pagamentos.php'),
    api('pedidos.php'),
  ]);

  document.querySelector('#companyName').textContent = empresaData.empresa.nome;
  document.querySelector('#welcomeText').textContent = internetData.cliente.nome || 'Minha conta';
  document.querySelector('#internetPanel').innerHTML = internetPanel(internetData);

  const payments = document.querySelector('#paymentsList');
  payments.innerHTML = pagamentosData.pagamentos.length
    ? pagamentosData.pagamentos.map(paymentItem).join('')
    : '<p class="empty-state">Nenhum pagamento encontrado.</p>';

  const orders = document.querySelector('#ordersList');
  orders.innerHTML = pedidosData.pedidos.length
    ? pedidosData.pedidos.map(orderItem).join('')
    : '<p class="empty-state">Nenhum pedido aberto.</p>';

  api('eventos.php', {
    method: 'POST',
    body: JSON.stringify({ evento: 'page_view', pagina: 'dashboard' }),
  }).catch(() => {});
}

document.querySelector('#paymentsList').addEventListener('click', async (event) => {
  const button = event.target.closest('[data-copy-pix]');
  if (!button) return;

  const code = decodeURIComponent(button.dataset.copyPix);
  try {
    await navigator.clipboard.writeText(code);
    button.textContent = 'Copiado';
  } catch (error) {
    button.textContent = 'Pix indisponivel';
  }
});

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
