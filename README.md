# PontoMobile

Aplicativo Android de registro de ponto desenvolvido em Flutter para a avaliação somativa de Recursos de Hardware do SENAI. O app combina autenticação Firebase, verificação da localização e desbloqueio biométrico local.

> **Documento README-001** · Versão 1.0 · Revisado em 2026-10-01  
> Projeto acadêmico. Esta documentação usa identificação, versão, escopo, procedimentos e limitações; não representa certificação ISO.

## Objetivo

Permitir que uma pessoa autenticada registre entrada e saída quando a localização do aparelho estiver a até 100 metros do local de trabalho configurado. Cada conta acessa apenas o próprio perfil e histórico.

## Funcionalidades

- Cadastro, login e logout com Firebase Authentication por e-mail e senha.
- Perfil armazenado no Cloud Firestore, sem salvar a senha.
- Proteção biométrica local opcional para uma sessão Firebase já autenticada.
- Consulta da localização, tratamento de permissões e cálculo da distância até o trabalho.
- Alternância entre os registros Entrada e Saída, com limite inclusivo de 100 metros.
- Histórico individual atualizado em tempo real, com data, hora, coordenadas e distância.
- Regras do Firestore versionadas no arquivo firestore.rules.

## Tecnologias

| Área | Tecnologia |
|---|---|
| Aplicativo | Flutter e Dart |
| Autenticação | Firebase Authentication |
| Persistência | Cloud Firestore |
| Localização | Geolocator |
| Biometria local | Local Auth |
| Testes | flutter_test |

As dependências estão declaradas em pubspec.yaml. O aplicativo não exige dependências adicionais para ser executado.

## Estrutura

~~~text
lib/
├── app/                 composição da aplicação e serviços
├── core/                configuração, regras, validações e tema
├── models/              perfil e registro de ponto
├── screens/             autenticação, ponto, histórico e perfil
├── services/            Firebase e recursos do dispositivo
├── firebase_options.dart configuração Firebase para Android
└── main.dart            inicialização do Firebase e do app
android/                 projeto Android e configuração Firebase
docs/                    instalação, uso e relatório
firestore.rules          regras locais de acesso ao Firestore
test/                     testes unitários e de widgets
~~~

## Instalação e execução

Consulte o [Guia de instalação e uso](docs/INSTALACAO_E_USO.md) para configurar o Firebase, iniciar um emulador e testar GPS e biometria.

~~~bash
flutter pub get
flutter analyze
flutter test
flutter run
~~~

O projeto Android está configurado para com.example.ponto_mobile. O Firebase precisa ter Authentication por e-mail/senha e Cloud Firestore configurados para que os fluxos remotos funcionem.

## Local de trabalho

As coordenadas fixas informadas para a Escola SENAI "Prof. João Baptista Salles da Silva", em Americana, são:

- Latitude: -22.7538572
- Longitude: -47.3513785

Os valores estão centralizados em lib/core/constants/app_config.dart. Para alterar o local, atualize essas constantes e o teste test/core/app_config_test.dart.

## Firebase e segurança

Os arquivos locais referenciam o projeto Firebase pontomobile-86dee. lib/firebase_options.dart e android/app/google-services.json são configurações de cliente geradas pelo FlutterFire. A chave de API Firebase identifica o projeto; ela não substitui autenticação, regras do Firestore ou Firebase App Check e não é uma senha. Não coloque chaves privadas, senhas de serviço ou arquivos de conta de serviço no aplicativo ou no controle de versão.

As regras locais restringem os documentos pelo UID autenticado. A existência de firestore.rules não prova que essas regras estejam publicadas no projeto remoto. Veja no guia como revisar e publicar as regras. A localização é calculada no cliente e pode ser falsificada; o app não deve ser usado como controle trabalhista antifraude sem validação confiável em servidor.

## Biometria

Ative **Desbloquear com biometria** na tela Perfil depois de cadastrar uma impressão digital ou outra biometria no dispositivo. Com a opção ativa, o app solicita confirmação ao abrir ou retomar a sessão. A preferência fica no perfil Firebase após o logout comum; **Sair e entrar com senha**, na tela de bloqueio, desativa a preferência. A biometria não cria uma sessão Firebase nem substitui a senha.

## Testes

Os testes cobrem a política de 100 metros, a sequência Entrada/Saída, configuração das coordenadas, validadores, modelos, erros, paths Firestore e fluxos de autenticação/biometria testáveis sem serviços externos.

~~~bash
flutter analyze
flutter test
~~~

## Documentos

- [Instalação e uso](docs/INSTALACAO_E_USO.md)
- [Relatório de implementação](docs/RELATORIO_IMPLEMENTACAO.md)
