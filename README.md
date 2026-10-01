# PontoMobile

Aplicativo Flutter de registro de ponto com autenticação Firebase, validação de localização em um raio de 100 metros e histórico individual no Cloud Firestore. Projeto acadêmico da avaliação somativa de Recursos de Hardware.

## Funcionalidades

- Cadastro e login por e-mail e senha com Firebase Authentication.
- Perfil associado ao UID autenticado, sem armazenar senha.
- Desbloqueio biométrico opcional da sessão Firebase já autenticada no dispositivo.
- Verificação do GPS e das permissões de localização.
- Registro de entrada e saída somente até 100 metros das coordenadas configuradas.
- Armazenamento de data/hora, latitude, longitude e distância.
- Histórico de registros atualizado por stream do Firestore.
- Regras Firestore locais com acesso restrito ao próprio UID.

## Tecnologias

- Flutter e Dart
- Firebase Core, Authentication e Cloud Firestore
- Geolocator
- Local Auth

As dependências já estão declaradas em `pubspec.yaml`; não é necessário instalar pacotes adicionais.

## Estrutura principal

```text
lib/
├── app/          # composição e serviços da aplicação
├── core/         # configuração, políticas, validações e tema
├── models/       # perfil e registro de ponto
├── screens/      # autenticação, ponto, histórico e perfil
├── services/     # Firebase e recursos do dispositivo
└── widgets/      # componentes reutilizáveis
test/             # testes de domínio, modelos, serviços e widgets
docs/             # relatório e instalação/uso
firestore.rules   # regras locais de segurança do Firestore
```

## Configuração e execução

Antes de executar, configure Firebase Authentication e Cloud Firestore conforme [Instalação e uso](docs/INSTALACAO_E_USO.md). O aplicativo usa as coordenadas fixas do SENAI Americana: latitude `-22.7538572` e longitude `-47.3513785`.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Para alterar o local de trabalho, edite as constantes em `lib/core/constants/app_config.dart`.

## Firebase

O projeto usa o Firebase `pontomobile-86dee` e o aplicativo Android `com.example.ponto_mobile`, preservando a configuração existente em `lib/firebase_options.dart` e `android/app/google-services.json`. O Firebase CLI confirmou o Firestore `(default)` em `southamerica-east1` e publicou `firestore.rules` em 1º de outubro de 2026.

Confirme no Console que o provedor E-mail/senha está habilitado. As regras em `firestore.rules` podem ser publicadas novamente após alterações com `firebase deploy --only firestore:rules --project pontomobile-86dee`. A validação do raio acontece no cliente. As regras restringem UID, formato e distância declarada, mas não conseguem comprovar que coordenadas GPS enviadas pelo aparelho são autênticas.

## Localização e biometria

O aplicativo solicita permissão de localização em tempo de execução e informa quando o GPS está desativado ou a permissão foi negada. A biometria é opcional e protege localmente uma sessão que já entrou pelo Firebase; ela não autentica diretamente no Firebase nem substitui a senha. A preferência biométrica fica salva no perfil mesmo após sair da conta; ao entrar novamente, o app solicita a biometria. Na tela de bloqueio, **Sair e entrar com senha** desativa essa preferência. O comportamento biométrico precisa ser verificado em um aparelho Android compatível.

## Testes

Os testes unitários cobrem configuração das coordenadas, limite inclusivo de 100 metros, sequência de entrada/saída, validação de formulários, modelos e mapeamento de erros. Testes de widget cobrem o auth gate e os formulários sem conectar ao Firebase real.

```bash
flutter analyze
flutter test
```

Consulte [o relatório de implementação](docs/RELATORIO_IMPLEMENTACAO.md) e [o guia de instalação e uso](docs/INSTALACAO_E_USO.md).
