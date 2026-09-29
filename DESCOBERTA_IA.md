# Descoberta com conversa e memória

## O que esta entrega faz

- Descoberta e Meu assistente abrem a mesma conversa, sem sequência fixa de perguntas.
- Histórico e mapa profissional são persistidos. A IA recebe até 24 mensagens recentes, limitadas por tamanho, e o mapa confirmado. Não há memória ilimitada.
- O modelo propõe interesses, experiências relatadas, preferências, temas de aprendizagem e um objetivo de exploração. Só a confirmação no aplicativo altera o mapa.
- O mapa permite adicionar, editar e remover itens. O histórico pode ser apagado separadamente, inclusive suas sugestões pendentes.
- O objetivo confirmado prioriza títulos relacionados em Vagas sem ocultar outras oportunidades. Temas confirmados priorizam cursos do catálogo. A conversa futura recebe todas as categorias do mapa.
- Experiências e interesses não viram certificados, notas de competência ou texto de currículo automaticamente.
- Sem API configurada, a conversa mostra sua indisponibilidade. O mapa manual funciona. Respostas simuladas existem somente nos testes.
- Contas Firebase usam perfis e caches separados. O perfil de visitante não é copiado para uma conta. Login carrega primeiro o perfil remoto. Recuperação de senha foi conectada ao Firebase.

## Testar sem gastar com IA

Execute `flutter pub get` e `flutter run -d chrome`. Abra Começar → Explorar protótipo → Jornada → Descoberta. Adicione um interesse, um objetivo e um tema em Quero aprender. Confira Capacitação e Vagas, recarregue e confirme que o mapa permanece.

Os testes simulam a resposta HTTP/modelo; não há chave nem chamada paga:

```
flutter test
cd backend
python -m pip install -r requirements.txt -r requirements-test.txt
python -m unittest -v test_discovery_api test_jobs_api
```

## Ativar depois

1. Crie/configure um projeto Firebase, um aplicativo web, Authentication com e-mail/senha e Firestore. Autorize os domínios usados e publique `firebase/firestore.rules`. Sem as regras de isolamento, não disponibilize o serviço.
2. Copie `firebase/web-config.example.json` para um arquivo local de configuração e preencha os valores públicos do seu aplicativo Firebase. Não inclua chave OpenAI nem credencial administrativa nesse arquivo.
3. No servidor, configure `OPENAI_API_KEY`, `OPENAI_MODEL` (modelo da sua conta com Responses e Structured Outputs), `FIREBASE_PROJECT_ID`, `CORS_ORIGINS` e `AI_USAGE_DB_PATH` em volume persistente. Configure credenciais padrão do Firebase Admin no provedor ou `GOOGLE_APPLICATION_CREDENTIALS` apontando para arquivo privado fora do repositório.
4. Use `.env` local privado, se desejar, e execute `uvicorn main:app --env-file .env --host 127.0.0.1 --port 8000` na pasta backend. Na hospedagem use HTTPS e o mecanismo do provedor para escutar sua porta pública. Configure limite de tamanho de requisição de 64 KB no proxy.
5. Compile com `flutter build web --no-web-resources-cdn --dart-define-from-file=firebase/web-config.local.json`. Hospede o conteúdo de `build/web`, não os arquivos antigos compilados na raiz do repositório.
6. Valide cadastro, login, recuperação, conversa real, confirmação, remoção, nova sessão e outra conta antes de convidar pessoas. Nenhum desses serviços externos foi provisionado nesta entrega.

## Limites e operação

- O endpoint /chat exige token Firebase válido. A chave OpenAI permanece no servidor. O perfil completo, currículo e documentos não são enviados: somente o mapa profissional e mensagens escolhidas pelo usuário.
- `AI_USER_DAILY_LIMIT` (50) e `AI_GLOBAL_DAILY_LIMIT` (500) limitam tentativas diárias; há 6 tentativas por minuto por usuário. Falhas também contam. São limites por chamadas, não um teto monetário garantido. Use alertas de custo e limites no provedor.
- O SQLite das cotas deve ser compartilhado pelos workers do mesmo servidor. Para várias réplicas, substitua por armazenamento central com incrementos atômicos antes de escalar.
- Histórico guardado: até 80 mensagens e aproximadamente 80 mil caracteres; mensagens mais antigas saem da conversa. Memórias confirmadas permanecem separadas. O contexto enviado é ainda menor. O assistente deve admitir quando não tem uma informação antiga.
- `store=False` evita guardar a resposta como estado da Responses API; não é uma promessa de retenção zero do provedor. O aplicativo armazena histórico em dispositivo/Firestore.
- A sincronização é por salvamento do documento, sem edição simultânea entre dispositivos nem resolução de conflitos. Falhas são mostradas; não trate a cópia local como backup garantido. Para uso público, implementar versionamento/merge e recuperação de alterações offline.
- Catálogo ainda limitado: os cursos conhecidos usam Excel, Comunicação, Organização e Atendimento. Um objetivo fora do catálogo não recebe requisitos inventados. Preferências livres são usadas pela conversa, sem filtros automáticos de localidade/horário nesta versão.
- Antes da abertura ao público: validar a qualidade das respostas com conversas reais autorizadas, acessibilidade, exclusão completa de conta e dados, política de privacidade e controle de convites se necessário. Esta é uma integração inicial para testes, não uma publicação de produção.

## Referências

- https://developers.openai.com/api/docs/guides/structured-outputs
- https://developers.openai.com/api/docs/guides/conversation-state
