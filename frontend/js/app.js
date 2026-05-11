const apiBase = window.location.pathname.startsWith('/frontend') ? '../api' : '/api';

const money = new Intl.NumberFormat('pt-BR', {
  style: 'currency',
  currency: 'BRL',
});

async function api(path, options = {}) {
  const response = await fetch(`${apiBase}/${path}`, {
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
    ...options,
  });

  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    throw new Error(data.erro || 'Nao foi possivel concluir a acao.');
  }

  return data;
}

function setTenantBrand(empresa) {
  document.querySelectorAll('#companyName').forEach((item) => {
    item.textContent = empresa.nome || 'ConectaPlay';
  });

  if (empresa.cor_primaria) {
    document.documentElement.style.setProperty('--primary', empresa.cor_primaria);
  }

  if (empresa.cor_secundaria) {
    document.documentElement.style.setProperty('--secondary', empresa.cor_secundaria);
  }
}

function videoCard(video) {
  const image = video.thumbnail_url || 'https://images.unsplash.com/photo-1601944177325-f8867652837f?auto=format&fit=crop&w=900&q=80';
  const duration = video.duracao_segundos ? `${Math.ceil(Number(video.duracao_segundos) / 60)} min` : 'Gratis';

  return `
    <article class="media-card">
      <img src="${image}" alt="">
      <div>
        <span>${video.categoria || 'Trailer'} - ${duration}</span>
        <h3>${video.titulo}</h3>
        <p>${video.descricao || ''}</p>
      </div>
    </article>
  `;
}

function partnerCard(parceiro) {
  const cupom = parceiro.cupom ? `<span class="coupon">${parceiro.cupom}</span>` : '';

  return `
    <article class="partner-card">
      <div class="partner-logo">${(parceiro.nome || 'P').slice(0, 2).toUpperCase()}</div>
      <div>
        <span>${parceiro.categoria || 'Parceiro'}</span>
        <h3>${parceiro.nome}</h3>
        <p>${parceiro.descricao || ''}</p>
        ${cupom}
      </div>
      ${parceiro.site_url ? `<a href="${parceiro.site_url}" target="_blank" rel="noopener" data-partner="${parceiro.id}">Abrir</a>` : ''}
    </article>
  `;
}

async function bootHome() {
  const [empresaData, videosData, parceirosData] = await Promise.all([
    api('empresas.php'),
    api('videos.php'),
    api('parceiros.php'),
  ]);

  setTenantBrand(empresaData.empresa);

  const videoList = document.querySelector('#videoList');
  videoList.innerHTML = videosData.videos.length
    ? videosData.videos.map(videoCard).join('')
    : '<p class="empty-state">Nenhum video disponivel no momento.</p>';

  const partnerList = document.querySelector('#partnerList');
  partnerList.innerHTML = parceirosData.parceiros.length
    ? parceirosData.parceiros.map(partnerCard).join('')
    : '<p class="empty-state">Nenhum parceiro cadastrado.</p>';

  partnerList.addEventListener('click', (event) => {
    const link = event.target.closest('[data-partner]');
    if (!link) return;

    api('parceiros.php', {
      method: 'POST',
      body: JSON.stringify({ parceiro_id: Number(link.dataset.partner) }),
    }).catch(() => {});
  });
}

bootHome().catch((error) => {
  document.body.insertAdjacentHTML('beforeend', `<p class="toast">${error.message}</p>`);
});
