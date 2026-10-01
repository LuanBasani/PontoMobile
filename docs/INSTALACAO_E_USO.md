# Guia de instalação e uso — PontoMobile

| Controle do documento | Informação |
|---|---|
| Identificação | DOC-02 |
| Versão | 1.0 |
| Revisão | 2026-10-01 |
| Finalidade | Instalar, configurar, executar e verificar o aplicativo |
| Público | Estudantes, avaliadores e mantenedores do projeto |
| Plataforma configurada | Android |

Este guia descreve a configuração local do projeto. A configuração de serviços Firebase na nuvem e os testes em hardware dependem de acesso ao Console Firebase e a um dispositivo ou emulador compatível.

## 1. Requisitos

- Flutter e Dart compatíveis com as restrições declaradas em pubspec.yaml (Dart ^3.12.2).
- Android Studio com Android SDK, ferramentas de plataforma e um emulador Android ou aparelho físico.
- Acesso ao projeto Firebase pontomobile-86dee para habilitar serviços ou publicar regras.
- Para biometria, dispositivo Android com biometria cadastrada ou emulador que ofereça sensor virtual.

O projeto está configurado para Android. As opções em lib/firebase_options.dart não configuram Web, iOS, macOS, Windows ou Linux.

Confirme a instalação do Flutter e as ferramentas Android:

~~~bash
flutter --version
flutter doctor
~~~

No Android Studio, instale o Android SDK pelo SDK Manager e crie/inicie um dispositivo virtual (AVD) pelo Device Manager, se não usar um aparelho físico.

## 2. Abrir o projeto e instalar dependências

Clone o repositório usando a URL fornecida pelo responsável pelo projeto, ou abra a pasta ponto_mobile já disponibilizada no Android Studio ou VS Code. No terminal, execute na raiz do projeto:

~~~bash
flutter pub get
~~~

## 3. Configuração do Firebase

O app referencia o projeto pontomobile-86dee e o aplicativo Android com.example.ponto_mobile. A configuração FlutterFire existente está em lib/firebase_options.dart e android/app/google-services.json; preserve esses arquivos ao trabalhar no projeto. Não execute flutterfire configure sem necessidade, pois isso pode substituir a configuração existente.

No [Console Firebase](https://console.firebase.google.com/), selecione o projeto e confirme:

1. Em **Authentication → Sign-in method**, habilite o provedor **E-mail/senha**.
2. Em **Firestore Database**, confirme que o banco (default) está criado e acessível.
3. Confira as regras efetivas do banco. O arquivo local firestore.rules restringe perfil e registros ao UID autenticado, mas só terá efeito remoto depois de publicado.

Para publicar as regras locais, instale/autentique o Firebase CLI, confira que o projeto selecionado é o correto e execute:

~~~bash
firebase login
firebase deploy --only firestore:rules --project pontomobile-86dee
~~~

Confirme no resultado do CLI que o deploy foi concluído. A presença do arquivo local não confirma publicação remota.

### Chave de API Firebase

A chave mostrada nos arquivos de configuração do cliente Firebase é um identificador público do projeto; ocultá-la do código Dart não a torna secreta, pois uma chave incluída em um app móvel pode ser extraída do pacote. Mantenha as regras Firestore corretas e, no Console Google Cloud em **APIs e serviços → Credenciais**, confira que a chave provisionada pelo Firebase está limitada às APIs Firebase necessárias. Não reutilize essa chave para APIs pagas ou serviços não Firebase. Use credenciais de servidor somente em ambiente de servidor, nunca no app.

Referência: [gerenciar chaves de API do Firebase](https://firebase.google.com/docs/projects/api-keys).

### Configuração Android do projeto

O identificador Android configurado é com.example.ponto_mobile. A integração Gradle aplica o plugin Google Services e o arquivo de configuração esperado é android/app/google-services.json. A Activity principal usa FlutterFragmentActivity para compatibilidade com Local Auth. As permissões de localização e biometria estão no AndroidManifest.xml. Preserve esses valores ao abrir o projeto; para publicar outro aplicativo Android, ele deve ser registrado no Firebase e sua configuração deve ser gerada para esse novo identificador.

## 4. Coordenadas do local de trabalho

O ponto de referência configurado é a Escola SENAI "Prof. João Baptista Salles da Silva", em Americana:

| Coordenada | Valor |
|---|---:|
| Latitude | -22.7538572 |
| Longitude | -47.3513785 |

Os valores fornecidos pelo responsável do projeto estão fixos em lib/core/constants/app_config.dart. Não é necessário passar --dart-define. Para usar outro local, altere as constantes e ajuste test/core/app_config_test.dart.

## 5. Permissões e localização

O manifesto Android declara ACCESS_COARSE_LOCATION e ACCESS_FINE_LOCATION. Na primeira consulta, conceda permissão de localização e mantenha o serviço de localização do dispositivo ativo. O app informa quando a permissão é negada, o serviço está desligado ou a posição não pode ser obtida.

O limite de registro é de 100 metros, incluindo exatamente 100 m. A tela mostra distância aproximada e habilita o registro apenas quando a posição mais recente está dentro do limite. A permissão do aparelho e a posição real precisam ser verificadas em dispositivo ou emulador.

## 6. Biometria

O manifesto declara USE_BIOMETRIC, e MainActivity estende FlutterFragmentActivity, conforme o fluxo de Local Auth configurado.

1. Cadastre biometria nas configurações de segurança do Android.
2. Entre no app com e-mail e senha.
3. Abra **Perfil** e habilite **Desbloquear com biometria**, confirmando a leitura solicitada.
4. Ao abrir ou retomar a sessão, confirme a identidade na solicitação biométrica.

No Android Emulator, cadastre uma impressão digital virtual nas configurações do sistema e use os controles do emulador para simular a leitura. A preferência biométrica fica no perfil Firebase após o logout comum. Na tela de bloqueio, **Sair e entrar com senha** encerra a sessão e desativa a preferência. A biometria protege uma sessão já autenticada; não substitui o login Firebase.

## 7. Executar o aplicativo

Inicie um emulador ou conecte um aparelho com depuração USB e execute:

~~~bash
flutter run
~~~

Crie uma conta com nome, e-mail e senha ou entre com uma conta existente. A tela **Ponto** apresenta a próxima ação e o estado da localização. Os registros alternam entre Entrada e Saída. A tela **Histórico** mostra os eventos da conta atual em ordem decrescente.

## 8. Análise e testes

Execute na raiz do projeto:

~~~bash
flutter analyze
flutter test
~~~

Os testes automatizados não dependem de uma conta Firebase real, GPS físico ou sensor biométrico. A integração com esses recursos exige uma verificação manual no ambiente configurado.

## 9. Estrutura dos dados

- Perfil: users/{uid}.
- Registros: users/{uid}/records/{recordId}.
- Campos do registro: tipo, recordedAt, latitude, longitude e distância calculada.
- O horário oficial gravado usa FieldValue.serverTimestamp(); uma estimativa local pode ser exibida enquanto uma gravação ainda está pendente.
- Senhas e dados biométricos não são gravados no Firestore.

## 10. Problemas comuns

| Sintoma | Verificação |
|---|---|
| Cadastro por e-mail não permitido | Habilite E-mail/senha no Firebase Authentication. |
| Falha ao acessar perfil ou histórico | Confira conexão, conta Firebase, existência do Firestore e regras publicadas. |
| Botão de ponto desabilitado | Atualize a localização; confira GPS, permissão e distância de até 100 m. |
| Biometria indisponível | Cadastre biometria Android; no emulador, configure uma impressão virtual e use o sensor virtual. |
| Nenhum dispositivo no flutter run | Inicie um AVD ou conecte aparelho com depuração USB habilitada. |
| Erro de API bloqueada | Revise as APIs permitidas para a chave Firebase no Console Google Cloud, sem remover APIs necessárias ao Firebase. |

## 11. Limitações e pendências

- A distância e as coordenadas vêm do dispositivo cliente e podem ser falsificadas. Regras Firestore não comprovam a presença física.
- A preferência biométrica é armazenada no perfil da conta; portanto, aplica-se ao perfil em outros dispositivos em que a conta entrar.
- O uso em produção requer revisão de segurança, política de privacidade, proteção contra falsificação de localização e configuração própria de assinatura Android.
- A configuração ativa de Authentication, estado atual do Firestore, restrições da chave e funcionamento em aparelho físico devem ser confirmados no ambiente do responsável. Este guia não declara essas verificações como realizadas.
