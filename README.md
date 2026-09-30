# Primeiro Passo 0.6 — protótipo multiplataforma

## O que esta versão oferece

- Uma base Flutter para Android, iOS e navegador.
- Navegação inferior em celulares e lateral em tablets e computadores a partir de 760 pixels.
- Cartões adaptáveis e conteúdo com largura confortável em telas grandes.
- Indicador circular da meta e ilustração editorial adulta no cartão inicial.
- Perfil e atividades armazenados no dispositivo/navegador. Não há sincronização entre dispositivos configurada.
- Vagas demonstrativas. Integrações de vagas e assistente requerem servidor próprio; consulte INTEGRACAO_VAGAS.md.

## Site

## Meu currículo

Acesse Perfil > Meu currículo ou a trilha Currículo inteligente. As abas Sobre, Competências, Formação e Experiências permitem complementar os dados manualmente. Cursos concluídos, objetivo, competências e dados já registrados no perfil são lidos automaticamente. Informações manuais permanecem salvas no dispositivo.

Escolha Visualizar currículo, ajuste os campos que deseja ocultar e abra a prévia A4. Baixar arquivo PDF usa exatamente o documento da prévia. No navegador o arquivo é baixado; nos aplicativos móveis a opção abre o compartilhamento do sistema, que permite salvar o arquivo. Use Voltar para retornar e ajustar. CPF, nascimento e sexo começam ocultos. Não há link público nem publicação automática de currículos.

Os dados pessoais das imagens de referência não foram incluídos como dados de demonstração. A prévia web inclui uma cópia local do visualizador PDF.js.

A pasta `build/web`, quando gerada, contém o site compilado. Sirva-a por HTTP ou HTTPS; abrir index.html diretamente pelo explorador não funciona corretamente.

Para desenvolvimento, com Flutter instalado:

```sh
flutter pub get
flutter run -d chrome
```

Para gerar os arquivos de hospedagem:

```sh
flutter build web --no-web-resources-cdn
```

Hospede o conteúdo de build/web com HTTPS para abrir em outros dispositivos. O endereço 127.0.0.1 funciona somente no computador que executa a prévia. Para uma subpasta, compile com `--base-href /nome-da-pasta/`.

O manifesto permite uso em janela independente quando o navegador oferece instalação/adicionar à tela inicial. Instalação e suporte variam conforme o navegador. Não foi configurada publicação pública nem proteção de acesso ao site: manter o repositório privado não protege automaticamente um site hospedado.

## Android

Instale Flutter e o Android SDK, aceite as licenças e conecte um aparelho/emulador:

```sh
flutter pub get
flutter run -d ID_DO_DISPOSITIVO
flutter build apk --debug
```

O APK de teste é gerado em build/app/outputs/flutter-apk/app-debug.apk. A distribuição em loja exige identificador definitivo e assinatura de produção. O projeto mantém o identificador de protótipo com.example.primeiro_passo.

## iPhone e iPad

Em um Mac com Xcode e ferramentas Flutter para iOS:

```sh
flutter pub get
flutter build ios --simulator
```

Abra ios/Runner.xcworkspace para configurar sua equipe e assinatura antes de instalar em aparelho físico ou distribuir. Não é possível gerar um aplicativo iOS assinado neste ambiente Windows.

## Computadores

Use a versão web em navegador moderno no Windows, macOS e Linux. Este pacote não inclui instaladores nativos para desktop.

## Testes

```sh
flutter test
```

Os testes responsivos exercitam as cinco abas em 320×700, 390×844, 844×390, 800×1000 e 1440×900. Isso não substitui testes em aparelhos físicos, Safari/iOS ou diferentes versões de sistema.

## Descoberta com conversa e memória

Veja [DESCOBERTA_IA.md](DESCOBERTA_IA.md) para conhecer a nova integração, testar sem API e configurar contas e IA depois.

