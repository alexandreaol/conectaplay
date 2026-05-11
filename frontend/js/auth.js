const apiBase = window.location.pathname.startsWith('/frontend') ? '../api' : '/api';

async function api(path, options = {}) {
  const response = await fetch(`${apiBase}/${path}`, {
    credentials: 'include',
    headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
    ...options,
  });
  const data = await response.json().catch(() => ({}));

  if (!response.ok) throw new Error(data.erro || 'Erro inesperado.');

  return data;
}

async function bootLogin() {
  const company = await api('empresas.php');
  document.querySelector('#companyName').textContent = company.empresa.nome;

  const form = document.querySelector('#loginForm');
  const message = document.querySelector('#loginMessage');

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    message.textContent = 'Entrando...';

    const data = Object.fromEntries(new FormData(form));

    try {
      await api('login.php', {
        method: 'POST',
        body: JSON.stringify(data),
      });
      window.location.href = 'dashboard.html';
    } catch (error) {
      message.textContent = error.message;
    }
  });
}

bootLogin().catch((error) => {
  document.querySelector('#loginMessage').textContent = error.message;
});
