# Integração de vagas — v0.5.4

## O que já está preparado

O aplicativo consulta uma API HTTP. O servidor incluído armazena vagas em SQLite, criando o banco vazio automaticamente na primeira operação. Não é necessário contratar um banco agora. Nenhuma vaga real ou empresa foi cadastrada nesta entrega.

Sem JOBS_API_URL, o app mostra o catálogo original identificado como demonstração. Com essa configuração, usa exclusivamente a API: uma lista vazia continua vazia, e falhas geram uma mensagem com opção de atualizar. Durante uma falha de atualização, os últimos resultados da sessão permanecem visíveis; eles não constituem um cache offline persistente.

O visual mantém cores, cartões e navegação. Cada vaga possui um ID estável; vagas de empresas diferentes com o mesmo título podem ser salvas e escolhidas separadamente. Os requisitos da meta são preservados no perfil. O botão Ver vaga abre o endereço externo; isso não confirma nem registra uma candidatura concluída. Sem link, o botão fica desabilitado.

## Usar agora

Faça backup do projeto existente e substitua lib e pubspec.yaml. Copie também pubspec.lock e test. Execute flutter pub get e flutter run -d chrome. Encerre a execução anterior antes de reiniciar. As pastas de plataforma e configurações Firebase existentes devem ser preservadas.

Este pacote contém código-fonte. Para criar um projeto separado, execute flutter create primeiro_passo e copie os arquivos acima para ele. Não é um APK.

## Ativar a API local no futuro (PowerShell)

Dentro da pasta backend, com Python instalado:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
$env:JOBS_ADMIN_TOKEN = [guid]::NewGuid().ToString('N') + [guid]::NewGuid().ToString('N')
$env:JOBS_DB_PATH = 'data/jobs.sqlite3'
$env:CORS_ORIGINS = 'http://localhost:5300'
.\.venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000
```

Guarde o token em local privado e reutilize-o nas reinicializações. Ele é exclusivo da administração do servidor, nunca do aplicativo. A chave OpenAI não é necessária para consultar ou cadastrar vagas. As variáveis são lidas do ambiente, não de um arquivo .env automaticamente.

Em outro terminal, na raiz Flutter:

```powershell
flutter run -d chrome --web-port=5300 --dart-define=JOBS_API_URL=http://127.0.0.1:8000
```

Acesse http://127.0.0.1:8000/docs para consultar os endpoints e cadastrar com PUT /admin/jobs/{job_id}, informando o token no campo X-Admin-Token. Use o conteúdo de backend/job.example.json como exemplo de corpo. O ID, como empresa-exemplo-001, deve continuar igual ao atualizar a mesma vaga. IDs devem ser globalmente únicos; prefixe-os com o identificador da fonte quando importar de várias empresas.

## Contrato para fontes futuras

GET /jobs?page=1&page_size=100 retorna:

```json
{
  "items": [
    {
      "id": "empresa-exemplo-001",
      "title": "Assistente Administrativo",
      "company": "Empresa Exemplo",
      "location": "Fortaleza, CE",
      "modality": "Híbrido",
      "description": "Descrição das atividades e requisitos.",
      "requirements": {"Excel": 0.65, "Organização": 0.75},
      "application_url": "https://example.com/vagas/001"
    }
  ],
  "has_more": false
}
```

id, title e company são obrigatórios. requirements usa valores entre 0 e 1; não extraímos pontuações automaticamente de textos das empresas. Use os nomes de competências do app para alimentar suas recomendações (Excel, Comunicação, Organização e Atendimento). Novos nomes aparecem nos cartões, mas exigem correspondência no catálogo de cursos para recomendar cursos dessas competências. Sem requisitos, a tela informa que a compatibilidade está indisponível. application_url aceita HTTP/HTTPS e pode ser nulo. Uma resposta inválida é tratada como falha, sem importar parcialmente o lote.

A API inclui somente vagas ativas, ordenadas pelo ID; o cliente consulta até 100 páginas de 100 itens, com limite de 15 segundos por requisição. Para volumes maiores, evolua para busca e paginação sob demanda. A busca atual por cargo, empresa, local e competência ocorre nos dados carregados no app.

PUT /admin/jobs/{job_id} cadastra ou substitui todos os campos da vaga. active=false oculta a vaga. DELETE /admin/jobs/{job_id} também a desativa, preservando o registro no banco. Ambas as operações exigem X-Admin-Token; sem JOBS_ADMIN_TOKEN, a administração fica desativada.

Um importador futuro pode ler uma API autorizada de uma empresa e escrever nesse contrato. Para PostgreSQL, MySQL ou outro banco, implemente o armazenamento no servidor mantendo GET /jobs; o aplicativo não precisa conhecer senhas nem a tecnologia do banco. Esta versão implementa SQLite, não conectores prontos para todos esses serviços.

## Ao disponibilizar na internet

Hospede o servidor com HTTPS, mantenha o banco em armazenamento persistente e configure CORS_ORIGINS com as origens exatas do app, separadas por vírgula. Configure JOBS_API_URL com o endereço público e faça uma nova compilação. localhost no celular aponta para o próprio celular. O token administrativo deve permanecer secreto; não há painel de empresas, contas de recrutadores ou permissões individuais nesta versão. O cadastro disponível é administrativo, pela API.

## Testes

Flutter: flutter test. Servidor: instale também requirements-test.txt e execute python -m unittest -v test_jobs_api na pasta backend. Veja VALIDACAO.md para os resultados desta entrega.
