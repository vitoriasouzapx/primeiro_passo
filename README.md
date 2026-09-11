# Primeiro Passo v0.5.4 — preparado para vagas de empresas

Mantém o layout e a correção da tela de Vagas da versão anterior. Agora inclui:

- API configurável para consultar vagas de empresas.
- Servidor com banco SQLite, cadastro protegido, atualização e desativação de vagas.
- Empresa, localização, modalidade, descrição e link de candidatura nos dados.
- Busca, filtro de salvas, atualização e tratamento de falhas.
- Identificadores exclusivos por vaga e preservação dos requisitos da meta no perfil.
- Modo de demonstração enquanto nenhuma API estiver configurada.

Nenhuma fonte externa está conectada e nenhuma hospedagem foi criada. Você pode continuar usando o app agora e ativar a integração futuramente.

Consulte INTEGRACAO_VAGAS.md para atualizar seu projeto, iniciar o servidor e cadastrar dados. O exemplo fictício está em backend/job.example.json. O pacote é código-fonte; preserve as pastas de plataforma do seu projeto Flutter atual.

Consulte VALIDACAO.md para os testes executados e suas limitações.
